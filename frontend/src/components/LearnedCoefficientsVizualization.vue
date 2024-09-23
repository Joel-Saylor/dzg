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
    CardContent: CardContent,
    CardTitle: CardTitle,
    CardDescription: CardDescription,
    CardHeader: CardHeader,
    ImageIcon: ImageIcon,
    StarFilledIcon: StarFilledIcon,
    TableIcon: TableIcon,
    Button: Button,
  },
  props: ["learnedCoefficients", "coefficentsSources"],
  data() {
    return {
      series: this.learnedCoefficients,
      chartOptions: {
        colors: ["#1C1427"],
        chart: {
          height: 350,
          type: "heatmap",
        },
        dataLabels: {
          enabled: false,
        },
        xaxis: {
          type: "category",
          categories: this.coefficentsSources,
        },
        plotOptions: {
          heatmap: {
            shadeIntensity: 0.8,
            radius: 0,
            useFillColorAsStroke: false,
          },
        },
      },
    };
  },
  methods: {
    downloadLearnedCoefficientsPng() {
      const node = document.getElementById("learned-coefficients-chart");
      domtoimage
        .toPng(node)
        .then(function (dataUrl) {
          const link = document.createElement("a");
          link.href = dataUrl;
          link.download = "learned-coefficients.png";
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
    downloadLearnedCoefficientsSvg() {
      const node = document.getElementById("learned-coefficients-chart");
      domtoimage
        .toSvg(node)
        .then(function (dataUrl) {
          const link = document.createElement("a");
          link.href = dataUrl;
          link.download = "learned-coefficients.svg";
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
    downloadLearnedCoefficientsXlsx() {
      let columns = [{ label: "sink", value: "sink" }];
      this.coefficentsSources.forEach((source) => {
        columns.push({ label: source, value: source });
      });

      let data = [
        {
          sheet: "Sheet 1",
          columns: columns,
          content: this.learnedCoefficients.map((coeff, index) => {
            let mappedData = {};
            coeff.data.forEach((value, index) => {
              mappedData[this.coefficentsSources[index]] = value;
            });
            return {
              sink: coeff.name,
              ...mappedData,
            };
          }),
        },
      ];
      let settings = {
        fileName: "LearnedCoefficients-DZG",
        writeMode: "writeFile",
        writeOptions: {},
      };

      xlsx(data, settings);
    },
  },
};
</script>
<template>
  <div class="w-full px-10 pb-10">
    <div class="flex gap-2 justify-end mb-2">
      <Button
        variant="outline"
        @click="downloadLearnedCoefficientsPng"
        class="text-xs"
      >
        <ImageIcon class="w-4 h-4 mr-2" />
        PNG
      </Button>
      <Button
        variant="outline"
        @click="downloadLearnedCoefficientsSvg"
        class="text-xs"
      >
        <StarFilledIcon class="w-4 h-4 mr-2" />
        SVG
      </Button>
      <Button @click="downloadLearnedCoefficientsXlsx" class="text-xs">
        <TableIcon class="w-4 h-4 mr-2" />
        XLSX
      </Button>
    </div>
    <Card id="learned-coefficients-chart">
      <CardHeader>
        <CardTitle>Learned Coefficients</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="flex gap-5 w-full">
          <div class="flex-grow">
            <apexchart
              type="heatmap"
              height="350"
              :options="chartOptions"
              :series="series"
            ></apexchart>
          </div>
          <div class="flex items-center">
            <div
              class="w-5 h-[80%] bg-gradient-to-b from-[#1C1427] to-[#FFFFFF]"
            ></div>
            <div class="flex flex-col justify-between h-[80%] ml-2 text-sm">
              <span>1.00</span>
              <span>0.75</span>
              <span>0.50</span>
              <span>0.25</span>
              <span>0.00</span>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
