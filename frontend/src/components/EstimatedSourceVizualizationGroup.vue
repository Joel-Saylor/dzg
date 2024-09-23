<script>
import VueApexCharts from "vue3-apexcharts";
import {
  Card,
  CardContent,
  CardTitle,
  CardDescription,
  CardHeader,
} from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ImageIcon, StarFilledIcon, TableIcon } from "@radix-icons/vue";
import { Button } from "@/components/ui/button";
import EstimatedSourceVizualization from "./EstimatedSourceVizualization.vue";

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
    Tabs: Tabs,
    TabsContent: TabsContent,
    TabsList: TabsList,
    TabsTrigger: TabsTrigger,
    EstimatedSourceVizualization,
  },
  props: ["sourceIdentificationPerSink", "sTabValue"],
  data() {
    return {};
  },
  methods: {},
  mounted() {},
};
</script>
<template>
  <Tabs :modelValue="sTabValue" class="w-full px-10 pb-10">
    <TabsContent
      v-for="sourceIdentification in sourceIdentificationPerSink"
      :value="sourceIdentification['name']"
      class="w-full"
    >
      <EstimatedSourceVizualization
        :loglikelihoodRatios="
          sourceIdentification['data']['loglikelihood_ratios']
        "
        :sources="sourceIdentification['data']['sources']"
      />
    </TabsContent>
    <TabsList class="mt-2" v-if="sourceIdentificationPerSink != null">
      <TabsTrigger
        v-for="sourceIdentification in sourceIdentificationPerSink"
        :value="sourceIdentification['name']"
        @click="$emit('sTabChange', sourceIdentification['name'])"
      >
        {{ sourceIdentification["name"] }}
      </TabsTrigger>
    </TabsList>
  </Tabs>
</template>
