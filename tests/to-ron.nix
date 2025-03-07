{ lib, runCommandLocal }:
let
  results = lib.runTests {
    testToRonAll = {
      expr = lib.cosmic.ron.toRON 0 {
        bool = true;
        char = {
          __type = "char";
          value = "a";
        };
        enum = {
          __type = "enum";
          variant = "FooBar";
        };
        float = 3.14;
        int = 333;
        list = [
          "foo"
          "bar"
          "baz"
        ];
        map = {
          __type = "map";
          value = [
            {
              key = "foo";
              value = "bar";
            }
          ];
        };
        namedStruct = {
          __type = "namedStruct";
          name = "foo";
          value = {
            bar = "baz";
          };
        };
        optional = {
          __type = "optional";
          value = "foo";
        };
        raw = {
          __type = "raw";
          value = "foo";
        };
        string = "foo";
        struct = {
          foo = "bar";
        };
        tuple = {
          __type = "tuple";
          value = [
            "foo"
            "bar"
            "baz"
          ];
        };
        tupleEnum = {
          __type = "enum";
          variant = "FooBar";
          value = [ "baz" ];
        };
      };
      expected = ''
        (
            bool: true,
            char: 'a',
            enum: FooBar,
            float: 3.14,
            int: 333,
            list: [
                "foo",
                "bar",
                "baz",
            ],
            map: {
                "foo": "bar",
            },
            namedStruct: foo(
                bar: "baz",
            ),
            optional: Some("foo"),
            raw: foo,
            string: "foo",
            struct: (
                foo: "bar",
            ),
            tuple: (
                "foo",
                "bar",
                "baz",
            ),
            tupleEnum: FooBar(
                "baz",
            ),
        )'';
    };
    testToRonBool = {
      expr = lib.cosmic.ron.toRON 0 true;
      expected = "true";
    };
    testToRonChar = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "char";
        value = "a";
      };
      expected = "'a'";
    };
    testToRonEnum = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "enum";
        variant = "FooBar";
      };
      expected = "FooBar";
    };
    testToRonFloat = {
      expr = lib.cosmic.ron.toRON 0 3.14;
      expected = "3.14";
    };
    testToRonInt = {
      expr = lib.cosmic.ron.toRON 0 333;
      expected = "333";
    };
    testToRonList = {
      expr = lib.cosmic.ron.toRON 0 [
        "foo"
        "bar"
        "baz"
      ];
      expected = ''
        [
            "foo",
            "bar",
            "baz",
        ]'';
    };
    testToRonMap = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "map";
        value = [
          {
            key = "foo";
            value = "bar";
          }
        ];
      };
      expected = ''
        {
            "foo": "bar",
        }'';
    };
    testToRonNamedStruct = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "namedStruct";
        name = "foo";
        value = {
          bar = "baz";
        };
      };
      expected = ''
        foo(
            bar: "baz",
        )'';
    };
    testToRonOptional = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "optional";
        value = "foo";
      };
      expected = ''Some("foo")'';
    };
    testToRonRaw = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "raw";
        value = "foo";
      };
      expected = "foo";
    };
    testToRonString = {
      expr = lib.cosmic.ron.toRON 0 "foo";
      expected = ''"foo"'';
    };
    testToRonStruct = {
      expr = lib.cosmic.ron.toRON 0 {
        foo = "bar";
      };
      expected = ''
        (
            foo: "bar",
        )'';
    };
    testToRonTuple = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "tuple";
        value = [
          "foo"
          "bar"
          "baz"
        ];
      };
      expected = ''
        (
            "foo",
            "bar",
            "baz",
        )'';
    };
    testToRonTupleEnum = {
      expr = lib.cosmic.ron.toRON 0 {
        __type = "enum";
        variant = "FooBar";
        value = [ "baz" ];
      };
      expected = ''
        FooBar(
            "baz",
        )'';
    };
  };
in
if results == [ ] then
  runCommandLocal "to-ron-success" { } "touch $out"
else
  runCommandLocal "to-ron-failure"
    {
      results = builtins.concatStringsSep "\n" (
        map (result: ''
          ${result.name}:
            expected: ${lib.generators.toPretty { } result.expected}
            actual: ${lib.generators.toPretty { } result.result}
        '') results
      );
    }
    ''
      echo -e "Tests failed:\\n\\n$results" >&2
      exit 1
    ''
