/*
Convert Titan Tactics DIALOGUE story files to JSON.
Stored per level and assigned triggers by file naming convention.
Usage:
yarn story <path where you keep your DIALOGUE files>
*/
import fs from "fs"
import yargs from "yargs"
import glob from "glob"

const args = yargs(process.argv.slice(2)).argv;

if(args._.length === 0) {
    console.log("Need input file");
}

function convert(input_file:string):any {
    let tokens = input_file.split("_");
    // let output_file = tokens[0] + ".json";
    let trigger = tokens.slice(1).join("_").replace(".dialogue", "");
    let input = fs.readFileSync(input_file).toString();
    let item = {} as any;
    let items = [] as Array<any>;
    let control_characters = [ "#", "/", ">", "$" ];
    for(let line of input.split("\n").map(item => item.trim())) {
        let new_item = () => {
            if(Object.keys(item).length > 0) {
                items.push(item);
                item = {} as any;
            }
        }
        if(line.startsWith("//") || line == "") continue;
        if(line.startsWith("#")) {
            new_item();
            item.avatar = line.slice(1).trim();
        }
        if(line.startsWith(">")) {
            new_item();
            let [item_type, item_target] = line.slice(1).trim().split(" ");
            item.type = item_type;
            item.target = item_target;
        }
        if(line.startsWith("$")) {
            new_item();
            item.type = "music";
            item.target = line.slice(1).trim();
        }
        if(!control_characters.includes(line[0])) {
            if(!item.text) item.text = [] as Array<string>;
            item.text.push(line);
        }    
    }
    items.push(item);
    
    let story = {
        "trigger": trigger,
        "story": items
    };
    return story;    
}

let output_files = {} as any;

glob((args._[0] as string) + "/*.dialogue", (error, input_files) => {
    if(input_files) {
        for(let input_file of input_files) {
            let tokens = input_file.split("_");
            let output_file = tokens[0] + ".json";
            let story = convert(input_file)
            console.log(story);
            if(!output_files[output_file]) {
                output_files[output_file] = [];
            }
            output_files[output_file].push(story);
        }
        for(let output_file in output_files) {
            fs.writeFileSync(output_file, JSON.stringify(output_files[output_file], null, 2));
        }
    }
});
