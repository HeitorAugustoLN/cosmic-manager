{ lib, runCommandLocal }:
let
  results = lib.runTests {
    testFromRonAll = {
      expr = lib.cosmic.ron.fromRON ''
        AllTests(
          bool: true,
          char: 'a',
          int: 1,
          float: 1.1,
          string: "abc",
          list: [
            1,
            2,
            3
          ],
          map: {
            "a": 1,
            2: 2
          },
          tuple: (
            1,
            2,
            3
          ),
          struct: (
            a: 1,
            b: 2
          ),
          namedStruct: NamedStruct(
            a: 1,
            b: 2
          ),
          enum: All,
          option: Some(Some(123)),
          tupleEnum: All(123),
          none: None,
          raw: foo
        )
      '';

      expected = {
        __type = "namedStruct";
        name = "AllTests";
        value = {
          bool = true;

          char = {
            __type = "char";
            value = "a";
          };

          int = 1;
          float = 1.1;
          string = "abc";

          list = [
            1
            2
            3
          ];

          map = {
            __type = "map";
            value = [
              {
                key = "a";
                value = 1;
              }
              {
                key = 2;
                value = 2;
              }
            ];
          };

          tuple = {
            __type = "tuple";
            value = [
              1
              2
              3
            ];
          };

          struct = {
            a = 1;
            b = 2;
          };

          namedStruct = {
            __type = "namedStruct";
            name = "NamedStruct";
            value = {
              a = 1;
              b = 2;
            };
          };

          enum = {
            __type = "raw";
            value = "All";
          };

          option = {
            __type = "optional";
            value = {
              __type = "optional";
              value = 123;
            };
          };

          tupleEnum = {
            __type = "enum";
            variant = "All";
            value = [
              123
            ];
          };

          none = {
            __type = "optional";
            value = null;
          };

          raw = {
            __type = "raw";
            value = "foo";
          };
        };
      };
    };

    testFromRonBool = {
      expr = lib.cosmic.ron.fromRON "true";
      expected = true;
    };

    testFromRonChar = {
      expr = lib.cosmic.ron.fromRON "'a'";

      expected = {
        __type = "char";
        value = "a";
      };
    };

    testFromRonEnum = {
      expr = lib.cosmic.ron.fromRON "FooBar";
      # Simple enum variants are basically the same as raw values. So I didn't
      # bother to add a special case for them in the fromRON function.
      expected = {
        __type = "raw";
        value = "FooBar";
      };
    };

    testFromRonFloat = {
      expr = lib.cosmic.ron.fromRON "3.14";
      expected = 3.14;
    };

    testFromRonInt = {
      expr = lib.cosmic.ron.fromRON "333";
      expected = 333;
    };

    testFromRonList = {
      expr = lib.cosmic.ron.fromRON ''
        [
          "foo",
          "bar",
          "baz"
        ]
      '';

      expected = [
        "foo"
        "bar"
        "baz"
      ];
    };

    testFromRonMap = {
      expr = lib.cosmic.ron.fromRON ''
        {
          "foo": (bar: "baz")
        }
      '';

      expected = {
        __type = "map";
        value = [
          {
            key = "foo";
            value = {
              bar = "baz";
            };
          }
        ];
      };
    };

    testFromRonNamedStruct = {
      expr = lib.cosmic.ron.fromRON ''
        foo(
          bar: "baz"
        )
      '';

      expected = {
        __type = "namedStruct";
        name = "foo";
        value = {
          bar = "baz";
        };
      };
    };

    testFromRonOptional = {
      expr = lib.cosmic.ron.fromRON ''Some("foo")'';

      expected = {
        __type = "optional";
        value = "foo";
      };
    };

    testFromRonRaw = {
      expr = lib.cosmic.ron.fromRON "foo";
      expected = {
        __type = "raw";
        value = "foo";
      };
    };

    testFromRonString = {
      expr = lib.cosmic.ron.fromRON ''"foo"'';
      expected = "foo";
    };

    testFromRonStruct = {
      expr = lib.cosmic.ron.fromRON ''( a: (b: (c: "foo")))'';
      expected.a.b.c = "foo";
    };

    testFromRonTuple = {
      expr = lib.cosmic.ron.fromRON ''("foo", "bar", "baz", 3.14, 333)'';
      expected = {
        __type = "tuple";
        value = [
          "foo"
          "bar"
          "baz"
          3.14
          333
        ];
      };
    };

    testToRonTupleEnum = {
      expr = lib.cosmic.ron.fromRON ''Path("/some/path", "/another/path")'';
      expected = {
        __type = "enum";
        variant = "Path";
        value = [
          "/some/path"
          "/another/path"
        ];
      };
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
