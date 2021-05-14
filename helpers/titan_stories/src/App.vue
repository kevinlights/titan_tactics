<template>
  <v-app>
    <v-app-bar app color="primary" dark>
      <span>Titan Stories</span>
      <v-btn-toggle v-model="level" dense group>
        <v-btn
          v-for="i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]"
          :key="i"
          :value="i"
          text
          >{{ i }}</v-btn
        >
      </v-btn-toggle>
      <v-spacer></v-spacer>
    </v-app-bar>

    <v-main>
      <router-view :level="level" />
    </v-main>
  </v-app>
</template>

<script lang="ts">
import Vue from "vue";

export default Vue.extend({
  name: "App",

  data: () => ({
    level: 1,
  }),
});
</script>
