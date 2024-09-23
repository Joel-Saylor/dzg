<script>
import InputVizualization from "../components/InputVizualization.vue";
import RankLossVizualization from "../components/RankLossVizualization.vue";
import LearnedDensitiesVizualization from "../components/LearnedDensitiesVizualization.vue";
import EstimatedSourceVizualizationGroup from "../components/EstimatedSourceVizualizationGroup.vue";
import LearnedCoefficientsVizualization from "../components/LearnedCoefficientsVizualization.vue";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Loader2 } from "lucide-vue-next";
import { toast } from "vue3-toastify";
import { TableIcon } from "@radix-icons/vue";
import { Card, CardContent, CardTitle, CardHeader } from "@/components/ui/card";
import xlsx from "json-as-xlsx";
const PageStates = {
  LOADING: "loading",
  PROCESSING: "processing",
  COMPLETE: "complete",
};
export default {
  components: {
    InputVizualization,
    RankLossVizualization,
    LearnedDensitiesVizualization,
    EstimatedSourceVizualizationGroup,
    LearnedCoefficientsVizualization,
    Button,
    Switch,
    Label,
    Input,
    Loader2,
    TableIcon,
    Card,
    CardContent,
    CardTitle,
    CardHeader,
  },
  data() {
    return {
      PageStates: PageStates,
      currentPageState: PageStates.LOADING,
      hideRankLoss: true,
      inputVizData: null,
      inputVizSinks: null,
      standardRankLossData: null,
      learnedDensitiesData: null,
      rankLossData: null,
      sourceIdentificationPerSink: null,
      sourceIdentificationTabValue: "",
      learnedCoefficients: null,
      learnedCoefficientsSources: null,
      inputVizTabValue: "",
      learnedDensitiesTabValue: "",
    };
  },
  methods: {
    handleTabChange(tabValue) {
      this.inputVizTabValue = tabValue;
    },
    handleLearnedDensitiesTabChange(tabValue) {
      this.learnedDensitiesTabValue = tabValue;
    },
    handleSourceIdentificationTabChange(tabValue) {
      this.sourceIdentificationTabValue = tabValue;
    },
    downloadInputVizXlsx() {
      let data = [];
      for (let i = 0; i < this.inputVizData.length; i++) {
        data.push({
          sheet: this.inputVizData[i]["name"],
          columns: Object.keys(this.inputVizData[i]["data"][0]).map((key) => {
            return {
              label: key,
              value: key,
            };
          }),
          content: this.inputVizData[i]["data"],
        });
      }
      let settings = {
        fileName: "InputVizData-DZG",
        writeMode: "writeFile",
        writeOptions: {},
      };

      xlsx(data, settings);
    },
    downloadLearnedDensitiesXlsx() {
      let data = [];
      for (let i = 0; i < this.learnedDensitiesData.length; i++) {
        data.push({
          sheet: this.learnedDensitiesData[i]["name"],
          columns: Object.keys(this.learnedDensitiesData[i]["data"][0]).map(
            (key) => {
              return {
                label: key,
                value: key,
              };
            }
          ),
          content: this.learnedDensitiesData[i]["data"],
        });
      }
      let settings = {
        fileName: "LearnedDensities-DZG",
        writeMode: "writeFile",
        writeOptions: {},
      };

      xlsx(data, settings);
    },
    downloadSourceEstimationXlsx() {
      let data = [];
      for (let i = 0; i < this.sourceIdentificationPerSink.length; i++) {
        data.push({
          sheet: this.sourceIdentificationPerSink[i]["name"],
          columns: Object.keys(this.sourceIdentificationPerSink[i]["data"]).map(
            (key) => {
              return {
                label: key,
                value: key,
              };
            }
          ),
          content: this.sourceIdentificationPerSink[i]["data"][
            "loglikelihood_ratios"
          ].map((loglikelihood_ratio, index) => {
            return {
              sources:
                this.sourceIdentificationPerSink[i]["data"]["sources"][index],
              loglikelihood_ratios: loglikelihood_ratio,
            };
          }),
        });
      }
      let settings = {
        fileName: "sourceIdentificationPerSink-DZG",
        writeMode: "writeFile",
        writeOptions: {},
      };

      xlsx(data, settings);
    },
  },
  async mounted() {
    const url = import.meta.env.PROD
      ? `/api/report/source-analysis/${this.$route.params.id}`
      : `${import.meta.env.VITE_BACKEND_URL}/api/report/source-analysis/${
          this.$route.params.id
        }`;
    try {
      const response = await fetch(url);
      const report = await response.json();
      if (response.status === 307) {
        this.$router.push(`/report/input-viz/${this.$route.params.id}`);
      }
      if (!response.ok) {
        console.log(report);
        throw new Error(report["message"]);
      }
      if (report["message"] === "Success") {
        const data = report["data"];
        this.selectedRank = data["best_rank"];
        this.inputVizData = data["measurement_data"];
        this.inputVizSinks = data["sinks"];
        this.inputVizTabValue = this.inputVizData[0]["name"];
        if (Object.hasOwn(data, "standard_rank_loss_data")) {
          this.standardRankLossData = data["standard_rank_loss_data"];
          this.rankLossData = data["rank_loss_data"];
          this.hideRankLoss = false;
        }
        this.learnedDensitiesData = data["learned_densities"];
        this.learnedDensitiesSources = data["learned_densities_sources"];
        this.learnedDensitiesTabValue = this.learnedDensitiesData[0]["name"];
        this.sourceIdentificationPerSink =
          data["source_identification_per_sink"];
        this.sourceIdentificationTabValue =
          this.sourceIdentificationPerSink[0]["name"];
        this.learnedCoefficients = data["learned_coefficients"];
        this.learnedCoefficientsSources = data["learned_coefficients_sources"];
        this.currentPageState = PageStates.COMPLETE;
      } else {
        this.message = report["message"];
        this.currentPageState = PageStates.PROCESSING;
      }
    } catch (error) {
      console.log(error);
      toast(error.message, {
        autoClose: false,
        position: "bottom-right",
        type: "error",
      });
    }
  },
};
</script>

<template>
  <div class="h-min-screen allbutFooter">
    <div v-if="currentPageState === PageStates.LOADING">
      <Loader2 class="w-10 h-10 animate-spin" />
    </div>
    <div v-else-if="currentPageState === PageStates.PROCESSING">
      <p class="text-center mt-5 text-xl">{{ message }}</p>
      <p class="text-center mt-5 text-xl font-medium">
        Refresh or check email to check for completion of step.
      </p>
    </div>
    <div v-else-if="currentPageState === PageStates.COMPLETE">
      <div id="input-viz-parent">
        <div class="flex justify-end mb-2 px-10">
          <Button @click="downloadInputVizXlsx">
            <TableIcon class="w-4 h-4 mr-2" />
            XLSX
          </Button>
        </div>
        <InputVizualization
          :inputVizData="inputVizData"
          :inputVizSinks="inputVizSinks"
          :tabValue="inputVizTabValue"
          @tabChange="handleTabChange"
        />
      </div>
      <div id="rank-loss-viz-parent" v-if="!hideRankLoss">
        <RankLossVizualization
          :rankLossData="rankLossData"
          :standardRankLossData="standardRankLossData"
          :selectedRank="selectedRank"
        />
      </div>
      <div id="learned-densities-viz-parent">
        <div class="flex justify-end mb-2 px-10">
          <Button @click="downloadLearnedDensitiesXlsx">
            <TableIcon class="w-4 h-4 mr-2" />
            XLSX
          </Button>
        </div>
        <LearnedDensitiesVizualization
          :learnedDensitiesData="learnedDensitiesData"
          :learnedDensitiesSources="learnedDensitiesSources"
          :tabValue="learnedDensitiesTabValue"
          @tabChange="handleLearnedDensitiesTabChange"
        />
      </div>
      <div id="source-estimation-viz-parent">
        <div class="flex justify-end mb-2 px-10">
          <Button @click="downloadSourceEstimationXlsx">
            <TableIcon class="w-4 h-4 mr-2" />
            XLSX
          </Button>
        </div>
        <EstimatedSourceVizualizationGroup
          :sourceIdentificationPerSink="sourceIdentificationPerSink"
          :sTabValue="sourceIdentificationTabValue"
          @sTabChange="handleSourceIdentificationTabChange"
        />
      </div>
      <div id="learned-coefficients-parent">
        <LearnedCoefficientsVizualization
          :learnedCoefficients="learnedCoefficients"
          :coefficentsSources="learnedCoefficientsSources"
        />
      </div>

      <div class="flex justify-center gap-5">
        <Button
          class="w-1/3 my-10"
          variant="outline"
          @click="
            this.$router.push(`/report/input-viz/${this.$route.params.id}`)
          "
        >
          Rerun Source Analysis
        </Button>
        <Button
          class="w-1/3 my-10"
          variant="destructive"
          @click="this.$router.push(`/`)"
        >
          Start Over
        </Button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.allbutFooter {
  min-height: calc(100vh - 265px);
}
</style>
