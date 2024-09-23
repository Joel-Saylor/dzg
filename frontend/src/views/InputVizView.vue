<script>
import InputVizualization from "../components/InputVizualization.vue";
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
    Button,
    Switch,
    Label,
    Card,
    CardContent,
    CardTitle,
    CardHeader,
    Input,
    TableIcon,
    Loader2,
  },
  data() {
    return {
      PageStates: PageStates,
      currentPageState: PageStates.LOADING,
      message: "", // PROCESSING page state
      inputVizData: {}, // COMPLETE page state
      inputVizSinks: [],
      inputVizTabValue: "",
      overrideCheck: false, // COMPLETE page state
      customRank: 0, // COMPLETE page state
      runningSourceAnalysis: false, // COMPLETE page state
    };
  },
  methods: {
    handleTabChange(tabValue) {
      console.log(tabValue);
      this.inputVizTabValue = tabValue;
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
        fileName: `InputVizData-DZG-${this.$route.params.id}`,
        writeMode: "writeFile",
        writeOptions: {},
      };

      xlsx(data, settings);
    },
    async runSourceAnalysis() {
      if (this.overrideCheck && this.customRank === 0) {
        toast("Cutom rank has to be greater than 1", {
          autoClose: false,
          position: "bottom-right",
          type: "error",
        });
        return;
      }
      const url = import.meta.env.PROD
        ? `/api/report/source-analysis/${this.$route.params.id}`
        : `${import.meta.env.VITE_BACKEND_URL}/api/report/source-analysis/${
            this.$route.params.id
          }`;
      try {
        const response = await fetch(url, {
          method: "POST",
          headers: {
            Accept: "application/json",
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            override_rank: this.overrideCheck,
            custom_rank: this.customRank,
          }),
        });
        if (!response.ok) {
          throw new Error("Starting source analysis failed.");
        }
        this.$router.push(`/report/source-analysis/${this.$route.params.id}`);
      } catch {
        toast(error.message, {
          autoClose: false,
          position: "bottom-right",
          type: "error",
        });
      }
    },
  },
  async mounted() {
    const url = import.meta.env.PROD
      ? `/api/report/input-viz/${this.$route.params.id}`
      : `${import.meta.env.VITE_BACKEND_URL}/api/report/input-viz/${
          this.$route.params.id
        }`;
    try {
      const response = await fetch(url);
      const report = await response.json();
      if (!response.ok) {
        console.log(report);
        throw new Error(report["message"]);
      }
      if (report["message"] === "Success") {
        const data = report["data"];
        this.inputVizData = data["measurement_data"];
        this.inputVizSinks = data["sinks"];
        this.inputVizTabValue = this.inputVizData[0]["name"];
        this.currentPageState = PageStates.COMPLETE;
        console.log(this.inputVizData);
        console.log(this.inputVizSinks);
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
      <div>
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
      <div class="flex w-full px-10 pb-10 gap-5">
        <Card class="w-2/3">
          <CardHeader>
            <CardTitle>Limitations</CardTitle>
          </CardHeader>
          <CardContent>
            <div class="p-6 pt-0">
              <ul class="list-disc px-7 text-lg">
                <li>
                  The algorithm calculates results for ranks 1-11 and returns
                  the optimum rank between
                  <strong>2-10</strong> based on the maximum curvature of the
                  error versus rank function. To check a specific rank, override
                  the rank identification and input the desired rank
                </li>
                <li class="mt-5">
                  <strong>Caution:</strong> We recommend running automatic rank
                  identification multiple times to determine if the selected
                  optimum rank is stable.
                </li>
              </ul>
            </div>
          </CardContent>
        </Card>
        <Card class="flex flex-col w-1/3">
          <CardHeader>
            <CardTitle>Run</CardTitle>
          </CardHeader>
          <CardContent>
            <div class="flex gap-4 mb-5">
              <Switch
                :checked="overrideCheck"
                @click="overrideCheck = !overrideCheck"
              />
              <h2>Bypass Automatic Rank Detection</h2>
            </div>
            <div class="mb-5" v-if="overrideCheck">
              <Label for="rank">Rank</Label>
              <Input
                id="rank"
                type="number"
                placeholder="Rank"
                v-model="customRank"
              />
            </div>
            <div class="flex flex-col w-full">
              <Button
                class="mb-5"
                @click="runSourceAnalysis"
                :disabled="runningSourceAnalysis"
              >
                <Loader2
                  class="w-4 h-4 mr-2 animate-spin"
                  v-if="runningSourceAnalysis"
                />
                Run Source Analysis
              </Button>
              <Button variant="destructive" @click="this.$router.push('/')">
                Start Over
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  </div>
</template>

<style scoped>
.allbutFooter {
  min-height: calc(100vh - 265px);
}
</style>
