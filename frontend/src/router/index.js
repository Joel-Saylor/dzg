import { createRouter, createWebHistory } from "vue-router";
import HomeView from "@/views/HomeView.vue";
import InputVizView from "@/views/InputVizView.vue";
import SourceAnalysisView from "@/views/SourceAnalysisView.vue";
import PrivacyPolicyView from "@/views/PrivacyPolicyView.vue";
import TermsView from "@/views/TermsView.vue";
import NotFoundView from "@/views/NotFoundView.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: HomeView,
    },
    {
      path: "/report/input-viz/:id",
      name: "input-viz-report",
      component: InputVizView,
    },
    {
      path: "/report/source-analysis/:id",
      name: "report",
      component: SourceAnalysisView,
    },
    {
      path: "/privacy-policy",
      name: "privacy-policy",
      component: PrivacyPolicyView,
    },
    {
      path: "/terms",
      name: "terms",
      component: TermsView,
    },
    {
      path: "/404",
      name: "404",
      component: NotFoundView,
    },
    {
      path: "/:catchAll(.*)",
      redirect: "/404",
    },
  ],
});

export default router;
