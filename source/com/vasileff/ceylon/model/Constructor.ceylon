shared
class Constructor(
        name, container, extendedType, isDeprecated = false, isSealed = false,
        isShared = false, unit = container.pkg.defaultUnit)
        extends TypeDeclaration()
        satisfies Functional {

    // TODO split Constructor into ValueConstructor and CallableConstructor
    shared actual [ParameterList+] parameterLists => [ParameterList.empty];

    shared actual Class container;
    shared actual String name;
    shared actual Type extendedType;
    shared actual Unit unit;

    shared actual Boolean isDeprecated;
    shared actual Boolean isSealed;
    shared actual Boolean isShared;

    shared actual [] caseTypes => [];
    shared actual [] caseValues => [];
    shared actual Boolean declaredVoid => false;
    shared actual Null qualifier => null;
    shared actual Null refinedDeclaration => null;
    shared actual [] satisfiedTypes => [];
    shared actual Null selfType => null;

    shared actual Boolean isActual => false;
    shared actual Boolean isAnnotation => false;
    shared actual Boolean isAnonymous => true;
    shared actual Boolean isDefault => false;
    shared actual Boolean isFinal => false;
    shared actual Boolean isFormal => false;
    shared actual Boolean isNamed => true;
    shared actual Boolean isStatic => false;

    shared actual
    Boolean inherits(TypeDeclaration that)
        // TODO does this make any sense? It checks a chain of constructors, and then,
        //      if one happens to extend a class, it checks that class's inheritance?
        =>  extendedType.declaration.inherits(that);

    shared actual
    Boolean canEqual(Object other)
        =>  other is Constructor;

    shared actual
    String string
        =>  "new ``partiallyQualifiedNameWithTypeParameters````valueParametersAsString``";
}
