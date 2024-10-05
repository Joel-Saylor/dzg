<script>
import { LineChart } from "@/components/ui/chart-line";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Card,
  CardContent,
  CardTitle,
  CardDescription,
  CardHeader,
} from "@/components/ui/card";
import { ImageIcon, StarFilledIcon } from "@radix-icons/vue";

import { Button } from "@/components/ui/button";
import domtoimage from "dom-to-image";
import { toast } from "vue3-toastify";
export default {
  components: {
    LineChart,
    Tabs,
    TabsContent,
    TabsList,
    TabsTrigger,
    Card,
    CardContent,
    CardHeader,
    CardTitle,
    CardDescription,
    ImageIcon,
    StarFilledIcon,
    Button,
  },
  props: ["learnedDensitiesData", "learnedDensitiesSources", "tabValue"],
  data() {
    return {
      roundedLearnedDensitiesData: [],
    };
  },
  methods: {
    downloadLearnedDensitiesPng() {
      const node = document.getElementById("learned-densities-chart");
      domtoimage
        .toPng(node)
        .then(function (dataUrl) {
          const link = document.createElement("a");
          link.href = dataUrl;
          link.download = "learned-densities.png";
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
    downloadLearnedDensitiesSvg() {
      const node = document.getElementById("learned-densities-chart");
      domtoimage
        .toSvg(node)
        .then(function (dataUrl) {
          const link = document.createElement("a");
          link.href = dataUrl;
          link.download = "learned-densities.svg";
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
  },
  mounted() {
    if (this.learnedDensitiesData !== null) {
      this.roundedLearnedDensitiesData = this.learnedDensitiesData.map(
        (measurement) => {
          return {
            name: measurement["name"],
            data: measurement["data"],
          };
        }
      );
    }
  },
};
</script>
<template>
  <Tabs :modelValue="tabValue" class="w-full px-10 pb-10">
    <Card id="learned-densities-chart">
      <CardHeader>
        <CardTitle>Learned Kernel Density Estimates</CardTitle>
        <CardDescription class="mt-2"
          ><div class="flex gap-3">
            <Button variant="outline" @click="downloadLearnedDensitiesPng">
              <StarFilledIcon class="w-4 h-4 mr-2" />
              PNG
            </Button>
            <Button variant="outline" @click="downloadLearnedDensitiesSvg">
              <ImageIcon class="w-4 h-4 mr-2" />
              SVG
            </Button>
          </div></CardDescription
        >
      </CardHeader>
      <CardContent>
        <div class="flex items-center">
          <div class="rotate-[-90deg] text-xl w-5">density</div>
          <TabsContent
            v-for="measurement in roundedLearnedDensitiesData"
            :value="measurement['name']"
            class="w-full"
          >
            <LineChart
              index="domain"
              :data="measurement['data']"
              :categories="learnedDensitiesSources"
            />.
          </TabsContent>
        </div>
      </CardContent>
    </Card>
    <TabsList class="mt-2 h-auto block">
      <TabsTrigger
        v-for="measurement in learnedDensitiesData"
        :value="measurement['name']"
        @click="$emit('tabChange', measurement['name'])"
      >
        {{ measurement["name"] }}
      </TabsTrigger>
    </TabsList>
  </Tabs>
</template>
