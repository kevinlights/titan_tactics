class_name Logger
extends Resource

var prefix = ""

func _init(logger_name):
    prefix = "[" + logger_name + "] "

func info(text1, text2="", text3="", text4="", text5=""):
    if OS.is_debug_build():
        text1 = text1 if text1 is String else JSON.print(text1, " ")
        text2 = text2 if text2 is String else JSON.print(text2, " ")
        text3 = text3 if text3 is String else JSON.print(text3, " ")
        text4 = text4 if text4 is String else JSON.print(text4, " ")
        text5 = text5 if text5 is String else JSON.print(text5, " ")
        var text = PoolStringArray([ text1, text2, text3, text4, text5 ]).join(" ")
        print(prefix + "[INFO] " + text)

func warning(text1, text2="", text3="", text4="", text5=""):
    if OS.is_debug_build():
        text1 = text1 if text1 is String else JSON.print(text1, " ")
        text2 = text2 if text2 is String else JSON.print(text2, " ")
        text3 = text3 if text3 is String else JSON.print(text3, " ")
        text4 = text4 if text4 is String else JSON.print(text4, " ")
        text5 = text5 if text5 is String else JSON.print(text5, " ")
        var text = PoolStringArray([ text1, text2, text3, text4, text5 ]).join(" ")
        print(prefix + "[WARN] " + text)

func error(text1, text2="", text3="", text4="", text5=""):
    if OS.is_debug_build():
        text1 = text1 if text1 is String else JSON.print(text1, " ")
        text2 = text2 if text2 is String else JSON.print(text2, " ")
        text3 = text3 if text3 is String else JSON.print(text3, " ")
        text4 = text4 if text4 is String else JSON.print(text4, " ")
        text5 = text5 if text5 is String else JSON.print(text5, " ")
        var text = PoolStringArray([ text1, text2, text3, text4, text5 ]).join(" ")
        printerr(prefix + "[ERROR] " + text)
