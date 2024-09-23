<script setup>
import { RouterView } from "vue-router";
</script>

<template>
  <a href="/"><h2 class="p-5 text-2xl text-center">DZ Grainalayzer</h2></a>
  <RouterView />
  <footer class="mt-10 px-10 py-5 bg-gray-100">
    <div class="flex justify-between w-[94%] mx-auto items-center">
      <div class="flex gap-3">
        <img class="w-[100px]" src="@/assets/ubc-logo.png" alt="ubc logo" />
        <img
          class="w-[100px] p-3"
          src="@/assets/eosc-logo.png"
          alt="ubc eosc logo"
        />
      </div class="flex gap-3">
      <div class="flex flex-col p-5">
        <a class="underline" href="/terms">Terms & Conditions</a>
        <a class="underline" href="/privacy-policy">Privacy Policy</a>
        <div class="text-center">Web app made by <a class="underline" href="https://stevepaul.xyz/" target="_blank">Steve Paul</a></div>
      </div>
    </div>
  </footer>
</template>

<style scoped></style>
