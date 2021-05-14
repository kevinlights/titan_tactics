/*
    Convert godot's TRES resource files to JSON
    usage:
    yarn cast <path where you keep your TRES files>
*/
import fs from "fs"
import yargs from "yargs"
import glob from "glob"

const args = yargs(process.argv.slice(2)).argv;

if(args._.length === 0) {
    console.log("Need input path");
}
function parse_resource(tres:string): any {
    let resources = [] as Array<any>;
    let resource = {} as any;
    let lookup = (resource_type: string, id: number) => {
        for(let resource of resources) {
            if(resource[resource_type] && resource[resource_type].id == id) {
                if(resource[resource_type].type === "Script") {
                    return resource[resource_type].path;
                }
                return resource.properties || resource[resource_type];
            }
        }
        return null;
    }
    for(let line of tres.split("\n")) {
        if(line.startsWith("[")) {
            if(Object.keys(resource).length > 0) {
                resources.push(resource);
                resource = {} as any;
            }
            let section = line.substr(1, line.length -2).split(" ");
            let section_name = section.shift() as string;
            if(section_name !== "resource") {
                resource[section_name] = {} as any;
                for(let item of section) {
                    let key_value = item.split("=");
                    let value = JSON.parse(key_value[1]);
                    resource[section_name][key_value[0]] = value;
                }    
            }
        } else {
            if(line.trim() !== "") {
                let key_value = line.split("=").map(item => item.trim());
                let value = key_value[1];
                try {
                    value = JSON.parse(key_value[1]);
                } catch(e) {
                }
                let match = String(value).match(/ExtResource\(\s(\d+)\s\)/);
                if(match) {
                    let ext_resource = lookup("ext_resource", parseInt(match[1], 10))
                    if(ext_resource) {
                        value = ext_resource;
                    }
                }
                match = String(value).match(/SubResource\(\s(\d+)\s\)/);
                if(match) {
                    let sub_resource = lookup("sub_resource", parseInt(match[1], 10))
                    if(sub_resource) {
                        value = sub_resource;
                    }
                } 
                resource.properties = resource.properties || {} as any;
                resource.properties[key_value[0]] = value;    
            }
        }
    }
    if(Object.keys(resource).length === 1) {
        resource = resource.properties;
    }
    return resource;
}

glob((args._[0] as string) + "/*.tres", (error, input_files) => {
    if(input_files) {
        for(let input_file of input_files) {
            let content = fs.readFileSync(input_file).toString();
            let resource = parse_resource(content);
            fs.writeFileSync(input_file + ".json", JSON.stringify(resource, null, 2));
        }
    }
});
