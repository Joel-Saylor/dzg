<script>
import VueApexCharts from "vue3-apexcharts";
import {
  Card,
  CardContent,
  CardTitle,
  CardDescription,
  CardHeader,
} from "@/components/ui/card";
import { ImageIcon, StarFilledIcon, TableIcon } from "@radix-icons/vue";
import { Button } from "@/components/ui/button";
import domtoimage from "dom-to-image";
import xlsx from "json-as-xlsx";
export default {
  components: {
    apexchart: VueApexCharts,
    Card: Card,
    CardHeader: CardHeader,
    CardTitle: CardTitle,
    CardDescription: CardDescription,
    CardContent: CardContent,
    ImageIcon: ImageIcon,
    StarFilledIcon: StarFilledIcon,
    TableIcon: TableIcon,
    Button: Button,
  },
  props: ["loglikelihoodRatios", "sources"],
  data() {
    return {
      maxValue: 0.0,
      minValue: 0.0,
      midValue: 0.0,
      series: [
        {
          data: [],
        },
      ],
      chartOptions: {
        chart: {
          height: 350,
          type: "scatter",
          zoom: {
            enabled: true,
            type: "xy",
          },
        },
        xaxis: {
          type: "numeric",
          tickAmount: 10,
          labels: {
            formatter: function (val) {
              return parseFloat(val).toFixed(0);
            },
          },
        },
        yaxis: {
          stepSize: 1,
          labels: {
            formatter: function (val) {
              return val.toFixed(0);
            },
          },
          min: 1,
        },
        tooltip: {
          enabled: true,
          custom: function ({ series, seriesIndex, dataPointIndex, w }) {
            return (
              '<div class="arrow_box p-5">' +
              "<p><strong>Log-Likelihood Ratio:</strong> " +
              w.config.series[seriesIndex].data[dataPointIndex]
                .loglikelihoodRatio +
              "</p>" +
              "<p><strong>Source:</strong> " +
              w.config.series[seriesIndex].data[dataPointIndex].y +
              "</p>" +
              "<p><strong>Grain index:</strong> " +
              w.config.series[seriesIndex].data[dataPointIndex].x +
              "</p>" +
              "</div>"
            );
          },
        },
      },
    };
  },
  methods: {
    interpolateColor(value, minValue, maxValue, colors) {
      maxValue = 1.0;
      if (value > maxValue) {
        value = maxValue;
      }
      if (minValue === maxValue) {
        throw new Error("minValue and maxValue cannot be the same");
      }

      if (colors.length !== 4) {
        throw new Error("There must be exactly 4 colors");
      }

      // Normalize the value within the range
      let normalizedValue = (value - minValue) / (maxValue - minValue);

      // Determine which segment the value falls into
      let segmentStart, segmentEnd, segmentValue;
      if (normalizedValue <= 1 / 3) {
        segmentStart = colors[0];
        segmentEnd = colors[1];
        segmentValue = normalizedValue / (1 / 3);
      } else if (normalizedValue <= 2 / 3) {
        segmentStart = colors[1];
        segmentEnd = colors[2];
        segmentValue = (normalizedValue - 1 / 3) / (1 / 3);
      } else {
        segmentStart = colors[2];
        segmentEnd = colors[3];
        segmentValue = (normalizedValue - 2 / 3) / (1 / 3);
      }

      // Interpolate each color channel within the segment

      let r =
        segmentStart[0] + (segmentEnd[0] - segmentStart[0]) * segmentValue;
      let g =
        segmentStart[1] + (segmentEnd[1] - segmentStart[1]) * segmentValue;
      let b =
        segmentStart[2] + (segmentEnd[2] - segmentStart[2]) * segmentValue;

      // Convert RGB to hex string
      const toHex = (c) => Math.round(c).toString(16).padStart(2, "0");

      return `#${toHex(r)}${toHex(g)}${toHex(b)}`;
    },
    hexToRgb(hex) {
      var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
      return result
        ? [
            parseInt(result[1], 16),
            parseInt(result[2], 16),
            parseInt(result[3], 16),
          ]
        : null;
    },
    downloadEstimatedSourcePng() {
      const node = document.getElementById("estimated-source-chart");
      domtoimage
        .toPng(node)
        .then(function (dataUrl) {
          const link = document.createElement("a");
          link.href = dataUrl;
          link.download = "estimated-source.png";
          link.click();
        })
        .catch(function (error) {
          toast(`Download ${error.message}`, {
            autoClose: 5000,
            position: "bottom-right",
            type: "error",
          });
        });
    },
    downloadEstimatedSourceSvg() {
      const node = document.getElementById("estimated-source-chart");
      domtoimage
        .toSvg(node)
        .then(function (dataUrl) {
          const link = document.createElement("a");
          link.href = dataUrl;
          link.download = "estimated-source.svg";
          link.click();
        })
        .catch(function (error) {
          toast(`Download ${error.message}`, {
            autoClose: 5000,
            position: "bottom-right",
            type: "error",
          });
        });
    },
    downloadEstimatedSourceXlsx() {
      let data = [
        {
          sheet: "Sheet 1",
          columns: [
            { label: "source", value: "source" },
            { label: "grain index", value: "grain index" },
          ],
          content: this.sources.map((source, index) => {
            return {
              source: source,
              "grain index": this.loglikelihoodRatios[index],
            };
          }),
        },
      ];
      let settings = {
        fileName: "EstimatedSource-DZG",
        writeMode: "writeFile",
        writeOptions: {},
      };

      xlsx(data, settings);
    },
  },
  mounted() {
    const nullRemovedloglikelihoodRatios = this.loglikelihoodRatios.map(
      (value) => (value === "null" ? 0.0 : value)
    );
    this.maxValue = Math.max(...nullRemovedloglikelihoodRatios);
    this.minValue = Math.min(...nullRemovedloglikelihoodRatios);
    this.midValue = (this.maxValue + this.minValue) / 2;
    for (let i = 0; i < nullRemovedloglikelihoodRatios.length; i++) {
      this.series[0].data.push({
        x: i,
        y: this.sources[i],
        loglikelihoodRatio: nullRemovedloglikelihoodRatios[i],
        fillColor: this.interpolateColor(
          nullRemovedloglikelihoodRatios[i],
          this.minValue,
          this.maxValue,
          [
            this.hexToRgb("#1C1427"),
            this.hexToRgb("#40394A"),
            this.hexToRgb("#7ECA9C"),
            this.hexToRgb("#CCFFBD"),
          ]
        ),
      });
    }
  },
};
</script>
<template>
  <Card id="estimated-source-chart" class="bg-white">
    <CardHeader>
      <CardTitle
        >Source attribution based on learned kernel density estimates</CardTitle
      >
      <CardDescription class="mt-2">
        <div class="flex gap-3">
          <Button variant="outline" @click="downloadEstimatedSourcePng">
            <StarFilledIcon class="w-4 h-4 mr-2" />
            PNG
          </Button>
          <Button variant="outline" @click="downloadEstimatedSourceSvg">
            <ImageIcon class="w-4 h-4 mr-2" />
            SVG
          </Button>
        </div></CardDescription
      >
    </CardHeader>
    <CardContent>
      <div class="flex items-center">
        <div class="rotate-[-90deg] text-xl w-5">source</div>
        <div class="flex gap-5 flex-grow">
          <div class="flex flex-col items-center flex-grow">
            <apexchart
              type="scatter"
              height="350"
              :options="chartOptions"
              :series="series"
              class="w-full"
            ></apexchart>
            <p class="text-lg">grain index</p>
          </div>
          <div class="flex items-center">
            <p class="rotate-[-90deg] text-lg w-7">confidence</p>
            <div
              class="w-5 h-full bg-gradient-to-b from-[#CCFFBD] via-[#7ECA9C] via-[#40394A] to-[#1C1427]"
            ></div>
            <div class="flex flex-col justify-between h-full ml-2">
              <span>&#8805;{{ Math.round(1 * 10) / 10 }}</span>
              <span>{{ Math.round(((1 + 0.5) / 2) * 10) / 10 }}</span>
              <span>{{ Math.round(0.5 * 10) / 10 }}</span>
              <span>{{ Math.round(((0.5 + 0.0) / 2) * 10) / 10 }}</span>
              <span>{{ Math.round(0.0 * 10) / 10 }}</span>
            </div>
          </div>
        </div>
      </div>
    </CardContent>
  </Card>
</template>
