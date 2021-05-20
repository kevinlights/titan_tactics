import fs from "fs"
import yargs from "yargs"
import glob from "glob"

const args = yargs(process.argv.slice(2)).argv;

if(args._.length === 0) {
    console.log("Need input path");
}

interface ISection {
    [key:string]:string;
};

interface ITriggerMap {
    [key:string]: Array<string>;
};

function parse_resource(content:string):Array<string> {
    const lines = content.split("\n");
    let section:ISection = {};
    let triggers:Set<string> = new Set();
    for(let line of lines) {
        if(line.trim().startsWith("[")) {
            if(Object.keys(section).length > 0) {
                if(section.control && section.character_class) {
                    triggers.add(section.name);
                }
                if(section.marker_name) {
                    triggers.add(section.marker_name);
                }
            }
            section = {};
        } else {
            let key_value = line.split("=").map(item => item.trim());
            try {
                section[key_value[0]] = JSON.parse(key_value[1]);
            } catch {
                section[key_value[0]] = key_value[1];
            }
        }
    }
    return Array.from(triggers);
}


glob((args._[0] as string) + "/*.tscn", (error, input_files) => {
    let trigger_map:ITriggerMap = {};
    if(input_files) {
        for(let input_file of input_files) {
            let content = fs.readFileSync(input_file).toString();
            let resource = parse_resource(content);
            let name = input_file.split("/").pop()?.replace("_3d.tscn", "").replace("_","");
            if(name) {
                trigger_map[name] = resource;
            }
        }
        fs.writeFileSync("triggers.json", JSON.stringify(trigger_map, null, 2));
    }
});