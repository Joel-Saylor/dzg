<script>
import {
    Card,
    CardContent,
    CardTitle,
    CardDescription,
    CardHeader,
} from "@/components/ui/card";
import { LineChart } from "@/components/ui/chart-line";
import { Button } from "@/components/ui/button";
import domtoimage from "dom-to-image";
import xlsx from "json-as-xlsx";
export default {
    components: {
        LineChart,
        Card,
        CardContent,
        CardHeader,
        CardTitle,
        CardDescription,
        Button,
    },
    props: ["standardRankLossData", "rankLossData", "selectedRank"],
    methods: {
        downloadCurvatureRelativeErrorPng() {
            const node = document.getElementById("curvature-relative-error");
            domtoimage
                .toPng(node)
                .then(function (dataUrl) {
                    const link = document.createElement("a");
                    link.href = dataUrl;
                    link.download = "curvature-relative-error.png";
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
        downloadCurvatureRelativeErrorSvg() {
            const node = document.getElementById("curvature-relative-error");
            domtoimage
                .toSvg(node)
                .then(function (dataUrl) {
                    const link = document.createElement("a");
                    link.href = dataUrl;
                    link.download = "curvature-relative-error.svg";
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
        downloadCurvatureRelativeErrorXlsx() {
            let data = [
                {
                    sheet: "Sheet 1",
                    columns: [
                        { label: "rank", value: "rank" },
                        { label: "loss", value: "loss" },
                    ],
                    content: this.standardRankLossData,
                },
            ];
            let settings = {
                fileName: "StandardRankLossData-DZG",
                writeMode: "writeFile",
                writeOptions: {},
            };

            xlsx(data, settings);
        },
        downloadRelativeErrorPng() {
            const node = document.getElementById("relative-error");
            domtoimage
                .toPng(node)
                .then(function (dataUrl) {
                    const link = document.createElement("a");
                    link.href = dataUrl;
                    link.download = "relative-error.png";
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
        downloadRelativeErrorSvg() {
            const node = document.getElementById("relative-error");
            domtoimage
                .toSvg(node)
                .then(function (dataUrl) {
                    const link = document.createElement("a");
                    link.href = dataUrl;
                    link.download = "relative-error.svg";
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
        downloadRelativeErrorXlsx() {
            let data = [
                {
                    sheet: "Sheet 1",
                    columns: [
                        { label: "rank", value: "rank" },
                        { label: "loss", value: "loss" },
                    ],
                    content: this.rankLossData,
                },
            ];
            let settings = {
                fileName: "RankLossData-DZG",
                writeMode: "writeFile",
                writeOptions: {},
            };

            xlsx(data, settings);
        },
    },
};
</script>

<template>
    <div class="flex justify-center space-x-4 p-12">
        <div class="w-1/2">
            <div class="flex gap-2 justify-end mb-2">
                <Button
                    variant="outline"
                    @click="downloadCurvatureRelativeErrorPng"
                    class="text-xs"
                >
                    PNG
                </Button>
                <Button
                    variant="outline"
                    @click="downloadCurvatureRelativeErrorSvg"
                    class="text-xs"
                >
                    SVG
                </Button>
                <Button
                    @click="downloadCurvatureRelativeErrorXlsx"
                    class="text-xs"
                >
                    XLSX
                </Button>
            </div>
            <Card id="curvature-relative-error">
                <CardHeader>
                    <CardTitle>Misfit versus Ranks</CardTitle>
                    <CardDescription
                        >Residual misfit between empirical variables (Y) and
                        reconconstructed variables (A B)</CardDescription
                    >
                </CardHeader>
                <CardContent>
                    <div class="flex items-end">
                        <div>
                            <div
                                class="mb-[125px] rotate-[-90deg] text-lg w-5 h-10 overflow-visible whitespace-nowrap"
                            >
                                relative error
                            </div>
                        </div>
                        <div class="flex flex-col items-center flex-grow">
                            <LineChart
                                index="rank"
                                :data="rankLossData"
                                :categories="['loss']"
                            />
                            <p class="text-lg">rank</p>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
        <div class="w-1/2">
            <div class="flex gap-2 justify-between mb-2">
                <div>
                    <Card>
                        <CardHeader class="px-3 py-2">
                            <CardTitle class="text-md p-0"
                                >Selected Rank:
                                <span
                                    class="px-4 py-1 m-1 bg-green-600 text-white rounded-md"
                                    >{{ selectedRank }}</span
                                ></CardTitle
                            >
                        </CardHeader>
                    </Card>
                </div>
                <div class="flex gap-2">
                    <Button
                        variant="outline"
                        @click="downloadRelativeErrorPng"
                        class="text-xs"
                    >
                        PNG
                    </Button>
                    <Button
                        variant="outline"
                        @click="downloadRelativeErrorSvg"
                        class="text-xs"
                    >
                        SVG
                    </Button>
                    <Button @click="downloadRelativeErrorXlsx" class="text-xs">
                        XLSX
                    </Button>
                </div>
            </div>
            <Card id="relative-error">
                <CardHeader>
                    <CardTitle>Optimum Rank</CardTitle>
                    <CardDescription
                        >Optimum rank identified as the maximum standard
                        curvature in this graph.</CardDescription
                    >
                </CardHeader>
                <CardContent>
                    <div class="flex items-end">
                        <div>
                            <div
                                class="mb-[165px] rotate-[-90deg] text-lg w-5 h-10 overflow-visible whitespace-nowrap"
                            >
                                curvature of relative error
                            </div>
                        </div>
                        <div class="flex flex-col items-center flex-grow">
                            <LineChart
                                index="rank"
                                :data="standardRankLossData"
                                :categories="['loss']"
                            />
                            <p class="text-lg">rank</p>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    </div>
</template>
