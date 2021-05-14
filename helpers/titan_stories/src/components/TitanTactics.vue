<template>
  <v-card>
    <v-toolbar dark color="primary">
      <v-btn icon dark @click="close_preview()">
        <v-icon>mdi-close</v-icon>
      </v-btn>
      <v-toolbar-title>Preview</v-toolbar-title>
      <v-spacer></v-spacer>
    </v-toolbar>
    <canvas id="canvas"></canvas>
  </v-card>
</template>