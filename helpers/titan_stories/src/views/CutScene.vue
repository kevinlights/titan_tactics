<template>
  <v-container>
    <v-progress-circular
      v-if="loading"
      indeterminate
      size="70"
    ></v-progress-circular>
    <v-container v-if="!loading">
      <v-toolbar dense floating>
        <v-btn icon @click="download()"><v-icon>mdi-download</v-icon></v-btn>
        <v-btn icon @click="preview()"><v-icon>mdi-play</v-icon></v-btn>
        <v-btn icon @click="text_mode = !text_mode"
          ><v-icon v-if="text_mode">mdi-chat</v-icon
          ><v-icon v-else>mdi-code-braces</v-icon></v-btn
        >
        <v-tabs v-model="tab">
          <v-tab
            v-for="item in stories"
            :key="item.trigger"
            :value="item.trigger"
            @click="trigger = item.trigger"
            >{{ item.trigger }}
          </v-tab></v-tabs
        >
      </v-toolbar>
      <v-textarea v-if="text_mode" v-model="json_story" auto-grow> </v-textarea>
      <v-timeline dense v-if="!text_mode">
        <v-timeline-item
          v-for="(item, index) in stories[tab].story"
          :key="index"
        >
          <template v-slot:icon>
            <v-avatar v-if="item.avatar">
              <v-img :src="'avatars/' + item.avatar + '.png'">
                <template v-slot:placeholder> </template>
              </v-img>
            </v-avatar>
            <v-icon v-if="item.type" color="white">{{
              icons[item.type]
            }}</v-icon>
          </template>
          <v-card class="elevation-2" v-if="item.text">
            <v-card-title
              v-if="item.avatar && edit_index !== index"
              class="headline"
              >{{ item.avatar }}</v-card-title
            >
            <v-card-text>
              <span v-if="edit_index !== index">
                <span v-for="(text, index) in item.text" :key="index"
                  >{{ text }}<v-icon color="grey">mdi-keyboard-return</v-icon
                  ><br
                /></span>
              </span>
              <v-text-field
                v-if="edit_index == index"
                v-model="item.avatar"
                placeholder="avatar name"
              ></v-text-field>
              <v-textarea
                placeholder="text"
                v-if="edit_index == index"
                v-model="edit_text"
              ></v-textarea>
            </v-card-text>
            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn icon v-if="index !== 0" @click="move_up(index)">
                <v-icon>mdi-arrow-up</v-icon>
              </v-btn>
              <v-btn
                icon
                v-if="index !== stories[tab].story.length - 1"
                @click="move_down(index)"
              >
                <v-icon>mdi-arrow-down</v-icon>
              </v-btn>

              <v-btn icon @click="edit_item(index)">
                <v-icon v-if="edit_index == index">mdi-pencil-off</v-icon>
                <v-icon v-else>mdi-pencil</v-icon>
              </v-btn>

              <v-btn icon @click="delete_item(index)">
                <v-icon>mdi-delete</v-icon>
              </v-btn>
            </v-card-actions>
          </v-card>
          <v-card v-if="item.type" color="primary" dark>
            <v-container>
              <v-row>
                <v-col v-if="edit_index != index">
                  <strong>{{ item.type }}</strong>
                  <span> {{ item.target }}</span>
                </v-col>
                <v-col v-if="edit_index == index">
                  <v-select
                    :items="action_items"
                    v-model="item.type"
                  ></v-select>
                </v-col>
                <v-col v-if="edit_index == index">
                  <v-text-field v-model="item.target"></v-text-field>
                </v-col>
                <v-col class="text-right">
                  <v-spacer></v-spacer>
                  <v-btn icon v-if="index !== 0" @click="move_up(index)">
                    <v-icon>mdi-arrow-up</v-icon>
                  </v-btn>
                  <v-btn
                    icon
                    v-if="index !== stories[tab].story.length - 1"
                    @click="move_down(index)"
                  >
                    <v-icon>mdi-arrow-down</v-icon>
                  </v-btn>

                  <v-btn icon @click="edit_item(index)">
                    <v-icon v-if="edit_index == index">mdi-pencil-off</v-icon>
                    <v-icon v-else>mdi-pencil</v-icon>
                  </v-btn>
                  <v-btn icon @click="delete_item(index)">
                    <v-icon>mdi-delete</v-icon>
                  </v-btn>
                </v-col></v-row
              >
            </v-container>
          </v-card>
        </v-timeline-item>
      </v-timeline>
      <v-btn color="primary" dark fab fixed bottom right @click="add_item()"
        ><v-icon>mdi-plus</v-icon></v-btn
      >
      <v-btn color="primary" dark fab fixed bottom right @click="add_item()"
        ><v-icon>mdi-plus</v-icon></v-btn
      >
    </v-container>
  </v-container>
</template>

<script lang="ts">
import Vue from "vue";
import TitanTactics from "../components/TitanTactics.vue";
// eslint-disable-next-line
declare var Engine: any;

const GODOT_CONFIG = {
  args: [],
  canvasResizePolicy: 1,
  executable: "game/Titan Tactics",
  experimentalVK: false,
  fileSizes: {
    "Titan Tactics.pck": 50240832,
    "Titan Tactics.wasm": 18105040,
  },
  gdnativeLibs: [],
};

interface IStoryItem {
  type: string;
  target: string;
  text: Array<string>;
  avatar: string;
  title: string;
}

interface IStory {
  trigger: string;
  story: Array<IStoryItem>;
}

export default Vue.extend({
  name: "CutScene",
  props: ["level"],
  data: () => ({
    loading: true,
    tab: 0 as number,
    text_mode: false,
    edit_index: -1,
    stories: [{}] as Array<IStory>,
    action_items: [
      "face",
      "select",
      "focus",
      "hint",
      "expect",
      "spawn",
      "emote",
      "music",
      "move",
    ],
    icons: {
      face: "mdi-face-profile",
      select: "mdi-select",
      focus: "mdi-eye",
      hint: "mdi-exclamation",
      expect: "mdi-alert",
      spawn: "mdi-flare",
      emote: "mdi-emoticon-cool",
      music: "mdi-music",
      move: "mdi-arrow-right",
    },
  }),
  watch: {
    level: "getLevel",
  },
  computed: {
    json_story: {
      get(): string {
        return JSON.stringify(this.stories[this.tab], null, 2);
      },
      set(value: string) {
        this.stories[this.tab] = JSON.parse(value);
      },
    },
    edit_text: {
      get(): string {
        if (this.edit_index === -1) return "";
        return this.stories[this.tab].story[this.edit_index].text.join("\n");
      },
      set(value: string) {
        this.stories[this.tab].story[this.edit_index].text = value.split("\n");
      },
    },
  },
  created() {
    this.getLevel();
  },
  methods: {
    add_action_item() {
      this.edit_index = this.stories[this.tab].story.length;
      this.stories[this.tab].story.push({
        type: "move",
        target: "",
      } as IStoryItem);
    },
    add_item() {
      this.edit_index = this.stories[this.tab].story.length;
      this.stories[this.tab].story.push({
        avatar: "",
        text: [] as Array<string>,
      } as IStoryItem);
    },
    edit_item(index: number) {
      if (this.edit_index === index) {
        this.edit_index = -1;
      } else {
        this.edit_index = index;
      }
    },
    delete_item(index: number) {
      this.stories[this.tab].story.splice(index, 1);
    },
    move_up(index: number) {
      const item = this.stories[this.tab].story.splice(index, 1);
      this.stories[this.tab].story.splice(index - 1, 0, item[0]);
    },
    move_down(index: number) {
      const item = this.stories[this.tab].story.splice(index, 1);
      this.stories[this.tab].story.splice(index + 1, 0, item[0]);
    },
    preview() {
      localStorage.level = this.level;
      localStorage.startup = JSON.stringify({ level: this.level - 1 });
      localStorage.stories = JSON.stringify(this.stories);
      window.open("game/titan_tactics.html", "_blank");
      // console.log("Preview level");
      // this.show_preview = true;

      // var enc = new TextEncoder();
      // const startupFile = enc.encode(
      //   JSON.stringify({
      //     level: this.level - 1,
      //   })
      // );
      // this.engine = new Engine(GODOT_CONFIG);
      // if (this.engine !== null) {
      //   this.engine
      //     .preloadFile(startupFile, "/resources/startup.json")
      //     .then(() => {
      //       this.engine
      //         .preloadFile(
      //           enc.encode(JSON.stringify(this.stories)),
      //           `/resources/story/level${this.level}.json`
      //         )
      //         .then(() => {
      //           this.engine.startGame();
      //         });
      //     });
      // }
    },
    download() {
      // const data = JSON.stringify(this.stories);
      const data = new Blob([JSON.stringify(this.stories, null, 2)], {
        type: "application/json",
      });
      var a = document.createElement("a");
      a.href = URL.createObjectURL(data);
      a.setAttribute("download", `level${this.level}.json`);
      a.click();
    },
    getLevel() {
      this.loading = true;
      fetch(`levels/level${this.level}.json`)
        .then((data) => data.json())
        .then((data) => {
          this.stories = data as Array<IStory>;
          this.loading = false;
          this.tab = 0;
        });
    },
  },
});
</script>
