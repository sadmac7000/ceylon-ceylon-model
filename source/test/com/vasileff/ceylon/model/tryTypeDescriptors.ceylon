import com.vasileff.ceylon.model {
    Module,
    ModuleImport
}
import ceylon.json {
    Object,
    parse
}
import com.vasileff.ceylon.model.json {
    JsonObject,
    LazyJsonModule
}
import com.vasileff.ceylon.model.runtime {
    TypeDescriptor
}

shared
void tryTypeDescriptors() {

    assert (exists unit
        =   modCeylonInteropDart.findDirectPackage("ceylon.interop.dart")?.defaultUnit);

    value td1
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::Entry<ceylon.language::String,ceylon.language::String>";
                [];
            };

    print("---------------");
    print(td1);
    print(td1.type);
    print(td1.type);

    value td2
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::Entry<ceylon.language::String,ceylon.language::String>";
                [];
            };

    print("---------------");
    print(td2);
    print(td2.type);
    print(td2.type);

    value td3
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::Entry<ceylon.language::String,ceylon.language::Float>";
                [];
            };

    print("---------------");
    print(td3);
    print(td3.type);
    print(td3.type);

    value tdString
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::String";
                [];
            };

    value tdFloat
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::Float";
                [];
            };

    value tdEntryWithSubstitutions1
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::Entry<^,^>";
                [tdString, tdFloat];
            };

    print("---------------");
    print(tdEntryWithSubstitutions1);
    print(tdEntryWithSubstitutions1.type);
    print(tdEntryWithSubstitutions1.type);

    value tdString2
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::String";
                [];
            };

    value tdFloat2
        =   TypeDescriptor {
                modCeylonInteropDart;
                "ceylon.language::Float";
                [];
            };

    value tdEntryWithSubstitutions2
        =   TypeDescriptor {
                modCeylonInteropDart;
                "^->^";
                [tdString2, tdFloat2];
            };

    print("---------------");
    print(tdEntryWithSubstitutions2);
    print(tdEntryWithSubstitutions2.type);
    print(tdEntryWithSubstitutions2.type);

    value myModule = modCeylonInteropDart;

    value argT = TypeDescriptor(myModule, "ceylon.language::Float?");
    value argU = TypeDescriptor(myModule, "ceylon.language::Boolean");

    print("---------------");
    print {
        TypeDescriptor {
            myModule;
            "<ceylon.language::String -> ^> | ^";
            [argT, argU];
        }.type; // <Entry<String, Float|Null>>|Boolean (type)
    };
}

JsonObject loadJson(String name) {
   assert (exists jsonString
        =   `module`.resourceByPath(name)?.textContent());

    assert (is Object jsonObject
        =   parse(jsonString));

    return jsonObject;
}

JsonObject _modCeylonLanguageJson => loadJson("ceylon.language-1.2.2-DP2-SNAPSHOT-dartmodel.json");
JsonObject _modCeylonInteropDartJson => loadJson("ceylon.interop.dart-1.2.2-dartmodel.json");

variable Module? _modCeylonLanguage = null;
variable Module? _modCeylonInteropDart = null;

Module modCeylonLanguage {
    if (exists m = _modCeylonLanguage) {
        // m may be partially initialized if there is a circular dependency
        return m;
    }
    value m = _modCeylonLanguage = LazyJsonModule(_modCeylonLanguageJson);
    m.moduleImports.add {
        ModuleImport {
            mod = modCeylonInteropDart;
            isShared = false;
        };
    };
    return m;
}

Module modCeylonInteropDart {
    if (exists m = _modCeylonInteropDart) {
        // m may be partially initialized if there is a circular dependency
        return m;
    }
    value m = _modCeylonInteropDart = LazyJsonModule(_modCeylonInteropDartJson);
    m.moduleImports.add {
        ModuleImport {
            mod = modCeylonLanguage;
            isShared = false;
        };
    };
    return m;
}
