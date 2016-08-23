--将table中的元素写到文件，元素之间用换行隔开
function writeToFile(tableName, fileName)
    local content = table.concat(tableName, "\n");
    local icon_name_txt = io.open(fileName, "w");
    icon_name_txt:write(content);
    icon_name_txt:flush();
    icon_name_txt:close();
end

--根据html内容获取图标名称列表
function getIconNameList(htmlString)
    local icon_name_txt_content = {};
    local matchIterator = string.gmatch(htmlString, "(%d+.?.?MS).png");

    for matchedStr in matchIterator do
        table.insert(icon_name_txt_content, matchedStr);
    end

    return icon_name_txt_content;
end

--根据html内容获取Pokemon名称列表
function getPokemonNameList(htmlString)
    local pokemon_name_txt_content = {};
    matchIterator = string.gmatch(htmlString, "<span style=\"color:#000;\">([%w%p♂♀é]+)</span></a>");

    --要不是Unown系列，我才不想搞那么复杂
    local isNeededConcat = false;   --是否需要将当前内容与上条内容拼接
    local concatTable = {"Unown_", ""}; --拼接模板

    for matchedStr in matchIterator do
        if isNeededConcat == true then
            concatTable[2] = matchedStr;
            matchedStr = table.concat(concatTable);
            table.insert(pokemon_name_txt_content, matchedStr);
            isNeededConcat = false;
        elseif matchedStr == "Unown" then
            isNeededConcat = true;
        else
            table.insert(pokemon_name_txt_content, matchedStr);
        end
    end

    return pokemon_name_txt_content;
end

--生成改名bash命令，只生成1~770的，后面的都是问号图标，全引用000.png，就不管他了
function generateBash(iconNameList, pokemonNameList)
    local concatTable = {"cp ./icon_origin/\"", "", ".png\" ./icon_renamed/\"", "", ".png\""};
    local bashTable = {};
    for index = 1,770,1 do
        concatTable[2] = iconNameList[index];
        concatTable[4] = pokemonNameList[index].."-"..iconNameList[index];
        table.insert(bashTable, table.concat(concatTable));
    end
    return bashTable;
end

--入口函数
function main()
    --打开pokemon.html并获取全部内容
    local pokemon_html = io.open("pokemon.html", "r");
    local pokemon_html_content = pokemon_html:read("*a");

    --图标部分
    local icon_name_txt_content = getIconNameList(pokemon_html_content);
    
    --pokemon名字部分
    local pokemon_name_txt_content = getPokemonNameList(pokemon_html_content);

    --生成bash命令
    local rename_all_icon_sh_content = generateBash(
                                            icon_name_txt_content, 
                                            pokemon_name_txt_content
                                        );

    --将各种内容写入文件
    writeToFile(icon_name_txt_content, "icon_name.txt");
    writeToFile(pokemon_name_txt_content, "pokemon_name.txt");
    writeToFile(rename_all_icon_sh_content, "rename_all_icon.sh");
end

--启动
main();
