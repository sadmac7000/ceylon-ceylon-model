import ceylon.test {
    assertTrue,
    test,
    assertFalse,
    assertEquals
}

import com.vasileff.ceylon.model {
    createType,
    ParameterList,
    TypeParameter,
    covariant,
    Module,
    Package,
    ClassDefinition,
    NothingDeclaration,
    InterfaceDefinition,
    typeFromNameLG,
    Scope,
    Type,
    ModuleImport,
    Value,
    Parameter,
    contravariant
}
import com.vasileff.ceylon.model.json {
    jsonModelUtil,
    keyName,
    keyPackage,
    keyTypeParams,
    keyModule,
    keyMetatype,
    metatypeTypeParameter,
    typeFromJson
}
import com.vasileff.ceylon.model.parser {
    parseTypeLG
}

shared
Module loadLanguageModule() {

    value ceylonLanguageModule
        =   Module(["ceylon", "language"], "0.0.0");

    value ceylonLanguagePackage
        =   Package(["ceylon", "language"], ceylonLanguageModule);

    ceylonLanguageModule.packages.add(ceylonLanguagePackage);

    // ceylon.language::Nothing
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        NothingDeclaration(ceylonLanguagePackage.defaultUnit);
    };

    // ceylon.language::Anything
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            unit = ceylonLanguagePackage.defaultUnit;
            name = "Anything";
            extendedTypeLG = null;
            caseTypesLG = [
                parseTypeLG("Object"),
                parseTypeLG("Null")
            ];
        };
    };

    // ceylon.language::Object
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Object";
            extendedTypeLG = parseTypeLG("Anything");
            isAbstract = true;
        };
    };

    // ceylon.language::Identifiable
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        InterfaceDefinition {
            container = ceylonLanguagePackage;
            name = "Identifiable";
        };
    };

    // ceylon.language::Basic satisfies Identifiable
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Basic";
            extendedTypeLG = parseTypeLG("Object");
            satisfiedTypesLG = [parseTypeLG("Identifiable")];
            isAbstract = true;
        };
    };

    // ceylon.language::Null
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Null";
            extendedTypeLG = parseTypeLG("Anything");
        };
    };

    // ceylon.language::Character
    ceylonLanguagePackage.defaultUnit.addDeclaration {
        ClassDefinition {
            container = ceylonLanguagePackage;
            name = "Character";
            extendedTypeLG = parseTypeLG("Object");
        };
    };

    // ceylon.language::String(List<Character>)
    value stringDefinition = ClassDefinition {
        container = ceylonLanguagePackage;
        name = "String";
        extendedTypeLG = parseTypeLG("Object");
    };

    ceylonLanguagePackage.defaultUnit.addDeclaration(stringDefinition);

    value stringArg = Value {
        container = stringDefinition;
        name = "characters";
        typeLG = parseTypeLG("{Character*}");
    };

    stringDefinition.addMembers { stringArg };

    stringDefinition.parameterList
        =   ParameterList([Parameter(stringArg)]);

    // ceylon.language::Entry
    value entryDeclaration
        =   ClassDefinition {
                container = ceylonLanguagePackage;
                name = "Entry";
                extendedTypeLG = parseTypeLG("Object");
                //parameterLists = [ParameterList.empty]; // TODO key, item
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(entryDeclaration);

    entryDeclaration.addMembers {
        TypeParameter {
            container = entryDeclaration;
            name = "Key";
            satisfiedTypesLG = [parseTypeLG("Object")];
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = entryDeclaration;
            name = "Item";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Iterable
    value iterableDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Iterable";
                // TODO satisfies Category
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(iterableDeclaration);

    iterableDeclaration.addMembers {
       TypeParameter {
            container = iterableDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
            defaultTypeArgumentLG = parseTypeLG("Anything");
        },
        TypeParameter {
            container = iterableDeclaration;
            name = "Absent";
            variance = covariant;
            selfTypeDeclaration = null;
            satisfiedTypesLG = [parseTypeLG("Null")];
            defaultTypeArgumentLG = parseTypeLG("Null");
        }
    };

    // ceylon.language::Sequential
    value sequentialDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Sequential";
                // TODO satisfies sequential<Element> & iterable<Element>
                // TODO cases Empty & Sequence
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(sequentialDeclaration);

    sequentialDeclaration.addMembers {
       TypeParameter {
            container = sequentialDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Sequence
    value sequenceDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Sequence";
                // TODO case types
                satisfiedTypesLG = [
                    (Scope scope) {
                        value declaration
                            =   assertedTypeDeclaration {
                                    scope.findDeclaration {
                                        declarationName = ["Sequential"];
                                    };
                                };
                        value elementTp
                            =   assertedTypeParameter {
                                    scope.getMember("Element");
                                };
                        return createType {
                            declaration = declaration;
                            typeArguments = map(zipEntries(
                                    declaration.typeParameters,
                                    {elementTp.type}));
                        };
                    },
                    (Scope scope) {
                        value declaration
                            =   assertedTypeDeclaration {
                                    scope.findDeclaration(["Iterable"]);
                                };
                        value elementTp
                            =   assertedTypeParameter {
                                    scope.getMember("Element");
                                };
                        return createType {
                            declaration = declaration;
                            typeArguments = map(zipEntries(
                                    declaration.typeParameters,
                                    {elementTp.type}));
                        };
                    }
                ];
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(sequenceDeclaration);

    sequenceDeclaration.addMembers {
       TypeParameter {
            container = sequenceDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Empty
    value emptyDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Empty";
                // TODO case types
                satisfiedTypesLG = [
                    (Scope scope)
                        =>  scope.unit.getSequentialType {
                                scope.unit.nothingDeclaration.type;
                            }
                ];
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(emptyDeclaration);

    // ceylon.language::Tuple
    value tupleDeclaration
        =   ClassDefinition {
                container = ceylonLanguagePackage;
                name = "Tuple";

                extendedTypeLG(Scope scope)
                    =>  scope.unit.objectDeclaration.type;

                satisfiedTypesLG = [
                    (Scope scope)
                        =>  scope.unit.getSequenceType {
                                assertedTypeParameter {
                                        scope.getMember("Element");
                                }.type;
                            }
                ];
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(tupleDeclaration);

    tupleDeclaration.addMembers {
        TypeParameter {
            container = tupleDeclaration;
            name = "Element";
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = tupleDeclaration;
            name = "First";
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = tupleDeclaration;
            name = "Rest";
            variance = covariant;
            selfTypeDeclaration = null;
        }
    };

    // ceylon.language::Callable
    value callableDeclaration
        =   InterfaceDefinition {
                container = ceylonLanguagePackage;
                name = "Callable";
            };

    ceylonLanguagePackage.defaultUnit.addDeclaration(callableDeclaration);

    callableDeclaration.addMembers {
        TypeParameter {
            container = callableDeclaration;
            name = "Return";
            variance = covariant;
            selfTypeDeclaration = null;
        },
        TypeParameter {
            container = callableDeclaration;
            name = "Arguments";
            variance = contravariant;
            selfTypeDeclaration = null;
        }
    };

    return ceylonLanguageModule;
}

shared test
void subtypesObjectNullAnything() {
    value languageModule = loadLanguageModule();
    value ceylonLanguagePackage = languageModule.ceylonLanguagePackage;
    value unit = ceylonLanguagePackage.defaultUnit;

    value anythingType = unit.anythingDeclaration.type;
    value objectType = unit.objectDeclaration.type;
    value nullType = unit.nullDeclaration.type;

    assertTrue(anythingType.isSupertypeOf(anythingType));
    assertTrue(anythingType.isSupertypeOf(objectType));
    assertTrue(anythingType.isSupertypeOf(unit.nullDeclaration.type));

    assertFalse(anythingType.isSubtypeOf(objectType));
    assertFalse(anythingType.isSubtypeOf(nullType));

    assertFalse(objectType.isSupertypeOf(nullType));
    assertFalse(objectType.isSubtypeOf(nullType));
}

shared test
void subtypesSimpleEntries() {
    value languageModule = loadLanguageModule();
    value ceylonLanguagePackage = languageModule.ceylonLanguagePackage;
    value unit = ceylonLanguagePackage.defaultUnit;

    value anythingType = unit.anythingDeclaration.type;
    value objectType = unit.objectDeclaration.type;

    function newEntry(Type key, Type item)
        =>  ceylonLanguagePackage.unit.entryDeclaration.appliedType(null, [key, item]);

    value objectAnything = newEntry(objectType, anythingType);
    value objectObject = newEntry(objectType, objectType);
    value stringObject
        =   typeFromJson {
                parseObject {
                    """{"md":"$", "nm":"Entry", "pk":"$", "tp":[
                            {"md":"$", "mt":"tp", "nm":"String", "pk":"$"},
                            {"md":"$", "mt":"tp", "nm":"Object", "pk":"$"}]}""";
                };
                ceylonLanguagePackage;
            };

    assertTrue(objectAnything.isSupertypeOf(objectObject));
    assertTrue(objectAnything.isSupertypeOf(stringObject));
    assertTrue(objectObject.isSupertypeOf(stringObject));

    assertFalse(objectAnything.isSubtypeOf(objectObject));
    assertFalse(objectAnything.isSubtypeOf(stringObject));
    assertFalse(objectObject.isSubtypeOf(stringObject));

    value objectObjectAnything = newEntry(objectType, objectAnything);
    value objectObjectObject = newEntry(objectType, objectObject);
    value objectStringObject = newEntry(objectType, stringObject);

    assertTrue(objectObject.isSupertypeOf(objectStringObject));
    assertFalse(objectObject.isSubtypeOf(objectStringObject));

    assertTrue(objectObjectAnything.isSupertypeOf(objectObjectObject));
    assertTrue(objectObjectAnything.isSupertypeOf(objectStringObject));
    assertTrue(objectObjectObject.isSupertypeOf(objectStringObject));

    assertFalse(objectObjectAnything.isSubtypeOf(objectObjectObject));
    assertFalse(objectObjectAnything.isSubtypeOf(objectStringObject));
    assertFalse(objectObjectObject.isSubtypeOf(objectStringObject));
}

shared test
void substitutionsSimple() {

    value mod = Module(["com", "example"], "0.0.0");
    mod.moduleImports.add(ModuleImport(loadLanguageModule(), true));

    value pkg = Package(["com", "example"], mod);
    mod.packages.add(pkg);

    value unit = pkg.defaultUnit;

    // Outer<T>
    value outerDeclaration
        =   ClassDefinition {
                container = pkg;
                name = "Outer";
                extendedTypeLG = unit.basicDeclaration.type;
            };

    outerDeclaration.addMembers {
        TypeParameter {
            container = outerDeclaration;
            name = "T";
        }
    };

    // Inner<U>
    value innerDeclaration
        =   ClassDefinition {
                container = outerDeclaration;
                name = "Inner";
                extendedTypeLG = unit.basicDeclaration.type;
            };

    innerDeclaration.addMembers {
        TypeParameter {
            container = innerDeclaration;
            name = "U";
        }
    };

    value tDeclaration
        =   assertedTypeParameter(outerDeclaration.getMember("T"));

    value uDeclaration
        =   assertedTypeParameter(innerDeclaration.getMember("U"));

    value innerType
        =   innerDeclaration.type;

    value substitutions
        =   map {
                tDeclaration -> unit.basicDeclaration.type,
                uDeclaration -> unit.objectDeclaration.type
            };

    value innerTypeSubstituted
        =   innerType.substitute(substitutions, emptyMap);

    //print(innerType.typeArguments);
    //print(innerType.qualifyingType?.typeArguments);

    //print(innerTypeSubstituted.typeArguments);
    //print(innerTypeSubstituted.qualifyingType?.typeArguments);

    assertEquals {
        expected = substitutions;
        actual = innerTypeSubstituted.typeArguments;
    };

    assertEquals {
        expected = map { tDeclaration->unit.basicDeclaration.type };
        actual = innerTypeSubstituted.qualifyingType?.typeArguments;
    };
}

shared test
void memberGenericTypesJson() {

    value mod = Module(["com", "example"], "0.0.0");
    mod.moduleImports.add(ModuleImport(loadLanguageModule(), true));

    value pkg = Package(["com", "example"], mod);
    mod.packages.add(pkg);

    value unit = pkg.defaultUnit;

    // Outer<T>
    value outerDeclaration
        =   ClassDefinition {
                container = pkg;
                name = "Outer";
                extendedTypeLG = unit.basicDeclaration.type;
            };

    unit.addDeclaration(outerDeclaration);

    outerDeclaration.addMembers {
        TypeParameter {
            container = outerDeclaration;
            name = "T";
        }
    };

    // Inner<U>
    value innerDeclaration
        =   ClassDefinition {
                container = outerDeclaration;
                name = "Inner";
                extendedTypeLG = unit.basicDeclaration.type;
            };

    outerDeclaration.addMembers { innerDeclaration };

    innerDeclaration.addMembers {
        TypeParameter {
            container = innerDeclaration;
            name = "U";
        }
    };

    value tDeclaration
        =   assertedTypeParameter(outerDeclaration.getMember("T"));

    value uDeclaration
        =   assertedTypeParameter(innerDeclaration.getMember("U"));

    "JSON for `Inner<Object>`"
    value jsonType1
        =   parseObject {
                 """
                    {"nm":"Outer.Inner",
                     "pk":".",
                     "tp":[{"md":"$",
                            "mt":"tp",
                            "nm":"Object",
                            "pk":"$"}]
                    }
                 """;
            };

    value loadedType1 = jsonModelUtil.loadType(pkg, jsonType1);

    assertEquals {
        expected = map {
            tDeclaration -> tDeclaration.type,
            uDeclaration -> unit.objectDeclaration.type
        };
        actual = loadedType1.typeArguments;
        "type arguments for Outer<T>.Inner<Object>";
    };

    "JSON for `Outer<String>.Inner<Object>`"
    value jsonType2
        =   map {
                keyName -> "Outer.Inner",
                keyPackage -> ".",
                keyTypeParams -> map {
                    "Outer.T" -> map {
                        keyModule -> "$",
                        keyMetatype -> metatypeTypeParameter,
                        keyName -> "String",
                        keyPackage -> "$"},
                    "Outer.Inner.U" -> map {
                        keyModule -> "$",
                        keyMetatype -> metatypeTypeParameter,
                        keyName -> "Object",
                        keyPackage -> "$"
                    }
                }
            };

    value loadedType2 = jsonModelUtil.loadType(pkg, jsonType2);

    assertEquals {
        expected = map {
            tDeclaration -> unit.stringDeclaration.type,
            uDeclaration -> unit.objectDeclaration.type
        };
        actual = loadedType2.typeArguments;
        "type arguments for Outer<String>.Inner<Object>";
    };

    assertEquals {
        expected = map {
            tDeclaration -> unit.stringDeclaration.type
        };
        actual = loadedType2.qualifyingType?.typeArguments;
        "type arguments for Outer<String>";
    };
}

shared test
void stringParameterType() {
    value languageModule = loadLanguageModule();
    value unit = languageModule.unit;

    assert (exists parameterType
        =   unit.stringDeclaration.parameterLists[0].parameters.first?.model?.type);

    value iterableCharacter
        =   unit.getIterableType(unit.characterDeclaration.type);

    value iterableObject
        =   unit.getIterableType(unit.objectDeclaration.type);

    assertTrue(parameterType.isSubtypeOf(iterableCharacter));
    assertTrue(parameterType.isSupertypeOf(iterableCharacter));

    assertTrue(parameterType.isSubtypeOf(iterableObject));
    assertFalse(parameterType.isSupertypeOf(iterableObject));
}
