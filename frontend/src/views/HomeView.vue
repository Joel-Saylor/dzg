<script>
import { Loader2 } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "vue3-toastify";
import { Card } from "@/components/ui/card";
export default {
  components: {
    Button,
    Input,
    Label,
    Loader2,
    Card,
  },
  data() {
    return {
      selectedFile: null,
      loading: false,
      projectName: "",
      email: "",
    };
  },
  methods: {
    handleFileUpload(event) {
      this.selectedFile = event.target.files[0];
    },
    async upload() {
      if (this.selectedFile == null) {
        toast(`Please select a file before uploading.`, {
          position: "bottom-right",
          type: "error",
          autoClose: false,
        });
        return;
      }
      if (this.projectName === "") {
        toast(`You didn't enter email and/or project name.`, {
          position: "bottom-right",
          type: "error",
          autoClose: false,
        });
        return;
      }
      this.loading = true;
      const formData = new FormData();
      formData.append("inputfile", this.selectedFile);
      formData.append("name", this.projectName);
      formData.append("email", this.email);

      try {
        const response = await fetch(
          import.meta.env.PROD
            ? `/api/upload/`
            : `${import.meta.env.VITE_BACKEND_URL}/api/upload/`,
          {
            method: "POST",
            body: formData,
          }
        );

        const report = await response.json();
        if (!response.ok) {
          console.log(report);
          throw new Error(report["message"]);
        }
        this.$router.push(`/report/input-viz/${report["data"]}`);
      } catch (error) {
        toast(error.message, {
          autoClose: false,
          position: "bottom-right",
          type: "error",
        });
        this.loading = false;
        this.selectedFile = null;
      }
    },
  },
};
</script>

<template>
  <div class="flex gap-10 w-[85%] mx-auto mt-10">
    <div class="w-[40%]">
      <p>
        <strong>DZ Grainalyzer </strong> implements the third-order constrained
        Tucker-1 tensor decomposition algorithm developed by Graham et al. (in
        review). The algorithm accepts as inputs an unlimited number of
        variables measured from individual grains or bulk aliquots in mixed
        samples. It couples a kernel density estimation technique with a
        matrix-tensor factorization to determine the distributions of those
        variables in latent sources and their mixing proportions in the
        empirical mixed samples.
      </p>
      <ul class="list-disc mt-10 line-">
        <li>
          It also implements the numerical test for rank estimation to define
          the optimum number of latent sources outlined by Graham et al. (in
          review).
        </li>
        <li class="mt-5">
          It uses the maximum-likelihood approach developed by Graham et al. (in
          review) to correlate the individual detrital grains to latent sources
          based on an unlimited number of features.
        </li>
      </ul>
    </div>
    <Card class="w-[60%] p-10 flex justify-center">
      <img
        class="w-auto h-auto object-contain"
        src="@/assets/fig1.jpg"
        alt="explanation figure"
      />
    </Card>
  </div>

  <Card class="flex w-[85%] mx-auto mt-10 p-10 justify-center gap-5 shadow-md">
    <div class="w-2/3">
      <h3 class="text-xl font-semibold">Steps</h3>
      <ol class="ml-5 mt-3 list-decimal">
        <li class="m-3.5">
          <h3 class="font-medium">Upload your data</h3>
          <ul class="mt-4 ml-5 list-disc">
            <li class="m-2">
              Should be in Excel file format (.xlsx) with
              <strong>1 sheet.</strong>
            </li>
            <li class="m-2">
              The first column should contain the SINK ids and should have the
              header value <strong>SINK ID</strong>.
            </li>
            <li class="m-2">
              The second column should contain the GRAIN ids and should have the
              header value <strong>GRAIN ID</strong>.
            </li>

            <li class="m-2">
              The rest of the columns should contain the measured variables with
              appropriate headers.
            </li>
            <li class="m-2">
              <a
                class="text-blue-600 underline"
                href="/sundell-example-file.xlsx"
                download=""
                >Example Data</a
              >
            </li>
          </ul>
        </li>
        <li class="m-3.5">
          <h3 data-v-b7ac5751="" class="font-medium">
            Visualize uploaded data
          </h3>
        </li>
        <li class="m-3.5">
          <h3 class="font-medium">
            Run optimum rank identification and source analysis
          </h3>
        </li>
      </ol>
      <p class="mt-7">
        Each step can take several minutes. Input an email to receive
        notification when that step is complete. Alternatively refresh the page
        to check whether the step is complete.
      </p>
    </div>

    <div class="w-1/3 flex gap-4 flex-col">
      <Label for="project-name">Project Name*</Label>
      <Input
        id="project-name"
        type="text"
        v-model="projectName"
        placeholder="ex: Saylor 2024 dataset"
      />
      <Label for="email">Email (Get notified when steps are complete)</Label>
      <Input
        id="email"
        type="email"
        v-model="email"
        placeholder="ex: example@ubc.ca"
      />
      <Label for="xlsx">Excel file upload*</Label>
      <Input id="xlsx" type="file" accept=".xlsx" @change="handleFileUpload" />
      <Button @click="upload" :disabled="loading">
        <Loader2 class="w-4 h-4 mr-2 animate-spin" v-if="loading" />
        Upload
      </Button>
    </div>
  </Card>

  <div class="flex flex-col gap-5 w-[85%] mx-auto mt-10">
    <h3 class="text-lg font-medium">
      If you use this resource to analyze your data, please cite the following
      references,
    </h3>
    <Card class="p-5 bg-gray-50">
      Graham, N., Richardson, N., Friedlander, M.P., and Saylor, J.E., in
      review, <br />
      &emsp; Tracing Sedimentary Origins in Multivariate Geochronology via
      Constrained Tensor Factorization, <br />&emsp;<i
        >Mathematical Geosciences.</i
      >
    </Card>
    <Card class="p-5 \ bg-gray-50">
      Saylor, J.E., Richardson, N., Graham, N., Lee., R., and Friedlander, M.P.,
      in preparation,<br />
      &emsp; Multivariate petrochronological mixture modelling: Application to
      characterizing sediment source Cu fertility,
      <br />&emsp;<i>Geology.</i>
    </Card>
  </div>
</template>

<style scoped>
.glow {
  animation: move 5s linear infinite;
  offset-path: rect(0% auto 100% auto);
  background: radial-gradient(#fff, #f1f5f9, transparent);
}

@keyframes move {
  0% {
    offset-distance: 0%;
  }

  100% {
    offset-distance: 100%;
  }
}
</style>
