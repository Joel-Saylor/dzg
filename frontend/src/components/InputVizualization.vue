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
import { Loader2 } from "lucide-vue-next";
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
        Loader2,
        Button,
        ImageIcon,
        StarFilledIcon,
    },
    props: ["inputVizData", "inputVizSinks", "tabValue"],
    data() {
        return {
            roundedInputVizData: [],
        };
    },
    methods: {
        downloadInputVizPng() {
            const node = document.getElementById("input-viz-chart");
            domtoimage
                .toPng(node)
                .then(function (dataUrl) {
                    const link = document.createElement("a");
                    link.href = dataUrl;
                    link.download = "input-viz.png";
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
        downloadInputVizSvg() {
            const node = document.getElementById("input-viz-chart");
            domtoimage
                .toSvg(node)
                .then(function (dataUrl) {
                    const link = document.createElement("a");
                    link.href = dataUrl;
                    link.download = "input-viz.svg";
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
        this.roundedInputVizData = this.inputVizData.map((measurement) => {
            return {
                name: measurement["name"],
                data: measurement["data"],
            };
        });
    },
};
</script>
<template>
    <Tabs :modelValue="tabValue" class="w-full px-10 pb-10">
        <Card id="input-viz-chart" class="bg-white">
            <CardHeader>
                <CardTitle
                    >Empirical Kernel Density Estimates of input
                    variables</CardTitle
                >
                <CardDescription class="mt-2">
                    <div class="flex gap-3" v-if="inputVizData != null">
                        <Button variant="outline" @click="downloadInputVizPng">
                            <StarFilledIcon class="w-4 h-4 mr-2" />
                            PNG
                        </Button>
                        <Button variant="outline" @click="downloadInputVizSvg">
                            <ImageIcon class="w-4 h-4 mr-2" />
                            SVG
                        </Button>
                    </div></CardDescription
                >
            </CardHeader>
            <CardContent
                v-if="inputVizData == null"
                class="flex flex-col gap-5 justify-center items-center h-40"
            >
                <Loader2 class="w-[55px] h-[55px] animate-spin" />
                <p class="text-center text-green-900 w-1/3">
                    Pro tip: The url generated for the report is valid for 24h.
                </p>
            </CardContent>
            <CardContent v-else>
                <div class="flex items-center">
                    <div class="rotate-[-90deg] text-xl w-5">density</div>
                    <TabsContent
                        v-for="measurement in roundedInputVizData"
                        :value="measurement['name']"
                        class="w-full"
                    >
                        <LineChart
                            index="domain"
                            :data="measurement['data']"
                            :categories="inputVizSinks"
                        />.
                    </TabsContent>
                </div>
            </CardContent>
        </Card>
        <TabsList class="mt-2" v-if="inputVizData != null">
            <TabsTrigger
                v-for="measurement in inputVizData"
                :value="measurement['name']"
                @click="$emit('tabChange', measurement['name'])"
            >
                {{ measurement["name"] }}
            </TabsTrigger>
        </TabsList>
    </Tabs>
</template>
