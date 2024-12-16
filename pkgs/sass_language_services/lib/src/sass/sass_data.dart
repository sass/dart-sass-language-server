import 'package:sass_language_services/src/sass/sass_module.dart';
import 'package:sass_language_services/src/sass/sass_module_function.dart';
import 'package:sass_language_services/src/sass/sass_module_variable.dart';

class SassData {
  final modules = [
    SassModule("sass:color",
        description: "Generate new colors based on existing ones.",
        reference:
            Uri.parse("https://sass-lang.com/documentation/modules/color"),
        functions: [
          SassModuleFunction(
            "adjust",
            description:
                "Increases or decreases one or more properties of `\$color` by fixed amounts. All optional arguments must be numbers.\n\nIt's an error to specify an RGB property at the same time as an HSL property, or either of those at the same time as an HWB property.",
            signature:
                r"($color, $red: null, $green: null, $blue: null, $hue: null, $saturation: null, $lightness: null, $whiteness: null, $blackness: null, $alpha: null, $space: null)",
            parameterSnippet: r"${1:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "alpha",
            description:
                r"Returns the alpha channel of `$color` as a number between **0** and **1**.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
          ),
          SassModuleFunction(
            "blackness",
            description:
                "Returns the HWB blackness of `\$color` as a number between **0%** and **100%**.\n\nThis function is deprecated in favor of color-space-friendly functions. See [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#blackness) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
          SassModuleFunction(
            "blue",
            description:
                "Returns the blue channel of `\$color` as a number between **0** and **255**.\n\nSee [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#blue) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
          SassModuleFunction(
            "change",
            description:
                "Sets one or more properties of `\$color` to new values.\n\nIt's an error to specify an RGB property at the same time as an HSL property, or either of those at the same time as an HWB property.",
            signature:
                r"($color, $red: null, $green: null, $blue: null, $hue: null, $saturation: null, $lightness: null, $whiteness: null, $blackness: null, $alpha: null, $space: null)",
            parameterSnippet: r"${1:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "channel",
            description:
                r"Returns the value of `$channel` in `$space`, which defaults to `$color`'s space. The `$channel` must be a quoted string, and the `$space` must be an unquoted string.",
            signature: r"($color, $channel, $space: null)",
            parameterSnippet: r"${1:color}, ${2:channel}",
            returns: "color",
          ),
          SassModuleFunction(
            "complement",
            description: r"Returns the RGB complement of `$color`",
            signature: r"($color, $space: null)",
            parameterSnippet: r"${1:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "grayscale",
            description:
                r"Returns a gray color with the same lightness as `$color`.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "green",
            description:
                "Returns the green channel of `\$color` as a number between **0** and **255**.\n\nThis function is deprecated in favor of color-space-friendly functions. See [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#green) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
          SassModuleFunction(
            "hue",
            description:
                "Returns the hue of `\$color` as a number between **0deg** and **360deg**.\n\nThis function is deprecated in favor of color-space-friendly functions. See [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#hue) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
          SassModuleFunction(
            "hwb",
            description:
                "Returns a color with the given hue, whiteness, and blackness and the given alpha channel.\n\nThis function is [deprecated](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#css-color-functions-in-sass) in favor of the CSS [hwb function](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/hwb).",
            signature: r"($hue, $whiteness, $blackness, $alpha: 1)",
            parameterSnippet: r"(${1:hue}, ${2:whiteness}, ${3:blackness})",
            returns: "color",
            deprecationMessage:
                "This function is deprecated in favor of the CSS hwb function.",
          ),
          SassModuleFunction(
            "ie-hex-str",
            description:
                r"Returns a string that represents `$color` in the #AARRGGBB format expected by `-ms-filter`.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "string",
          ),
          SassModuleFunction(
            "invert",
            description: r"Returns the inverse of `$color`.",
            signature: r"($color, $weight: 100, $space: null)",
            parameterSnippet: r"${1:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "is-in-gamut",
            description:
                r"Returns whether `$color` is [in a given gamut](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#working-with-gamut-boundaries). Defaults to the space the color is defined in. The `$space` must be an unquoted string.",
            signature: r"($color, $space: null)",
            parameterSnippet: r"${1:color}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "is-legacy",
            description:
                r"Returns whether `$color` is in a [legacy color space](https://sass-lang.com/documentation/values/colors#legacy-color-spaces).",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "is-missing",
            description:
                r"Returns whether `$channel` is [missing](https://sass-lang.com/documentation/values/colors/#missing-channels) in `$color`. The `$channel` must be a quoted string.",
            signature: r"($color, $channel)",
            parameterSnippet: r"${1:color}, ${2:channel}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "is-powerless",
            description:
                r"Returns whether `$color`'s $channel is [powerless](https://sass-lang.com/documentation/values/colors/#powerless-channels) in the `$space`. The `$channel` must be a quoted string and the `$space` must be an unquoted string.",
            signature: r"($color, $channel, $space: null)",
            parameterSnippet: r"${1:color}, ${2:channel}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "lightness",
            description:
                "Returns the HSL lightness of `\$color` as a number between **0%** and **100%**.\n\nThis function is deprecated in favor of color-space-friendly functions. See [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#lightness) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
          SassModuleFunction(
            "mix",
            description:
                r"Returns a color that's a mixture of `$color1` and `$color2`.",
            signature: r"($color1, $color2, $weight: 50%)",
            parameterSnippet: r"${1:color}, ${2:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "red",
            description:
                "Returns the red channel of `\$color` as a number between **0** and **255**.\n\nThis function is deprecated in favor of color-space-friendly functions. See [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#red) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
          SassModuleFunction(
            "same",
            description:
                r"Returns whether `$color1` and `$color2` visually render as the same color.",
            signature: r"($color1, $color2)",
            parameterSnippet: r"${1:color1}, ${2:color2}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "saturation",
            description:
                "Returns the HSL saturation of `\$color` as a number between **0%** and **100%**.\n\nThis function is deprecated in favor of color-space-friendly functions. See [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#saturation) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
          SassModuleFunction(
            "scale",
            description:
                "Fluidly scales one or more properties of `\$color`. Each keyword argument must be a number between **-100%** and **100%**.\n\nIt's an error to specify an RGB property at the same time as an HSL property, or either of those at the same time as an HWB property.",
            signature:
                r"($color, $red: null, $green: null, $blue: null, $saturation: null, $lightness: null, $whiteness: null, $blackness: null, $alpha: null, $space: null)",
            parameterSnippet: r"${1:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "space",
            description:
                r"Returns the name of $color's space as an unquoted string.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "string",
          ),
          SassModuleFunction(
            "to-gamut",
            description:
                r"Returns a visually similar color to `$color` in the gamut of `$space`, which defaults to `$color`'s space. The `$space` must be an unquoted string. `$method` is mandatory until a default browser behavior is established.",
            signature: r"($color, $space: null, $method: local-minde | clip)",
            parameterSnippet: r"${1:color}, \\$method: ${2|local-minde,clip|}",
            returns: "color",
          ),
          SassModuleFunction(
            "to-space",
            description:
                r"Converts `$color` into the given `$space`, which must be an unquoted string.",
            signature: r"($color, $space: null)",
            parameterSnippet: r"${1:color}",
            returns: "color",
          ),
          SassModuleFunction(
            "whiteness",
            description:
                "Returns the HWB whiteness of `\$color` as a number between **0%** and **100%**.\n\nThis function is deprecated in favor of color-space-friendly functions. See [the announcement post](https://sass-lang.com/blog/wide-gamut-colors-in-sass/#deprecated-functions) and [documentation](https://sass-lang.com/documentation/modules/color/#whiteness) for how to migrate.",
            signature: r"($color)",
            parameterSnippet: r"${1:color}",
            returns: "number",
            deprecationMessage:
                "This function is deprecated in favor of color-space-friendly functions.",
          ),
        ]),
    SassModule("sass:list",
        description: "Modify or read lists.",
        reference:
            Uri.parse("https://sass-lang.com/documentation/modules/list"),
        functions: [
          SassModuleFunction(
            "append",
            description:
                r"Returns a copy of `$list` with `$val` added to the end.",
            signature: r"($list, $val, $separator: auto)",
            parameterSnippet: r"${1:list}, ${2:value}",
            returns: "list",
          ),
          SassModuleFunction(
            "index",
            description:
                "Returns the index of `\$value` in `\$list`.\n\nNote that the index **1** indicates the first element of the list in Sass.",
            signature: r"($list, $value)",
            parameterSnippet: r"${1:list}, ${2:value}",
            returns: "number",
          ),
          SassModuleFunction(
            "is-bracketed",
            description: r"Returns whether `$list` has square brackets (`[]`).",
            signature: r"($list)",
            parameterSnippet: r"${1:list}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "join",
            description:
                r"Returns a new list containing the elements of `$list1` followed by the elements of `$list2`.",
            signature: r"($list1, $list2, $separator: auto, $bracketed: auto)",
            parameterSnippet: r"${1:list}, ${2:list}",
            returns: "list",
          ),
          SassModuleFunction(
            "length",
            description:
                r"Returns the number of elements in `$list`. Can also return the number of pairs in a map.",
            signature: r"($list, $value)",
            parameterSnippet: r"${1:list}, ${2:value}",
            returns: "number",
          ),
          SassModuleFunction(
            "separator",
            description:
                r"Returns the name of the separator used by `$list`, either **space**, **comma**, or **slash**. Returns **space** if `$list` doesn't have a separator.",
            signature: r"($list)",
            parameterSnippet: r"${1:list}",
            returns: "string",
          ),
          SassModuleFunction("nth",
              description:
                  "Returns the element of `\$list` at index `\$n`.\n\nIf `\$n` is negative, it counts from the end of `\$list`. Throws an error if there is no element at index `\$n`.\n\nNote that the index **1** indicates the first element of the list in Sass.",
              signature: r"($list, $n)",
              parameterSnippet: r"${1:list}, ${2:number}",
              returns: "T"),
          SassModuleFunction(
            "set-nth",
            description:
                "Returns a copy of `\$list` with the element at index `\$n` replaced with `\$value`.\n\nIf `\$n` is negative, it counts from the end of `\$list`. Throws an error if there is no existing element at index `\$n`.\n\nNote that the index **1** indicates the first element of the list in Sass.",
            signature: r"($list, $n, $value)",
            parameterSnippet: r"${1:list}, ${2:number}, ${3:value}",
            returns: "list",
          ),
          SassModuleFunction(
            "slash",
            description:
                r"Returns a slash-separated list that contains `$elements`.",
            signature: r"($elements...)",
            parameterSnippet: r"${1:elements}",
            returns: "list",
          ),
          SassModuleFunction(
            "zip",
            description:
                "Combines every list in \$lists into a single list of sub-lists.\n\nEach element in the returned list contains all the elements at that position in \$lists. The returned list is as long as the shortest list in \$lists.\n\nThe returned list is always comma-separated and the sub-lists are always space-separated.",
            signature: r"($lists...)",
            parameterSnippet: r"${1:lists}",
            returns: "list",
          ),
        ]),
    SassModule("sass:map",
        description: "Modify or read maps.",
        reference: Uri.parse("https://sass-lang.com/documentation/modules/map"),
        functions: [
          SassModuleFunction(
            "deep-merge",
            description:
                "Identical to map.merge(), except that nested map values are also recursively merged.",
            signature: r"($map1, $map2)",
            parameterSnippet: r"${1:map}, ${2:map}",
            returns: "map",
          ),
          SassModuleFunction(
            "deep-remove",
            description:
                r"Returns a map without the right-most `$key`. Any keys to the left are treated as a path through the nested map, from left to right.",
            signature: r"($map, $key, $keys...)",
            parameterSnippet: r"${1:map}, ${2:key}",
            returns: "map",
          ),
          SassModuleFunction("get",
              description:
                  r"Returns the value in `$map` associated with the right-most `$key`. Any keys to the left are treated as a path through the nested map, from left to right. Returns `null` if there is no `$key` in `$map`.",
              signature: r"($map, $key, $keys...)",
              parameterSnippet: r"${1:map}, ${2:key}",
              returns: "T"),
          SassModuleFunction(
            "has-key",
            description:
                r"Returns true if `$map` has a value with the right-most `$key`. Any keys to the left are treated as a path through the nested map, from left to right.",
            signature: r"($map, $key, $keys...)",
            parameterSnippet: r"${1:map}, ${2:key}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "keys",
            description:
                r"Returns a comma-separated list of all the keys in `$map`.",
            signature: r"($map)",
            parameterSnippet: r"${1:map}",
            returns: "list",
          ),
          SassModuleFunction(
            "merge",
            description:
                r"Merges the two maps at either side of the `$args` list. Between the two maps is an optional path to a nested map in `$map1` which will be merged, instead of the root map. The value from `$map2` will be used if both maps have the same key.",
            signature: r"($map1, $args...)",
            parameterSnippet: r"${1:map}, ${2:map}",
            returns: "map",
          ),
          SassModuleFunction("remove",
              description:
                  r"Removes values in `$map` associated with any of the `$keys`.",
              signature: r"($map, $keys...)",
              parameterSnippet: r"${1:map}, ${2:key}",
              returns: "T"),
          SassModuleFunction("set",
              description:
                  r"Sets `$value` in `$map` at the location of the right-most `$key`. Any keys to the left are treated as a path through the nested map, from left to right. Creates nested maps at `$keys` if none exists.",
              signature: r"($map, $keys..., $key, $value)",
              parameterSnippet: r"${1:map}, ${2:key}, ${3:value}",
              returns: "T"),
          SassModuleFunction(
            "values",
            description:
                r"Returns a comma-separated list of all the values in `$map`.",
            signature: r"($map)",
            parameterSnippet: r"${1:map}",
            returns: "list",
          ),
        ]),
    SassModule("sass:math",
        description: "Work on numbers with functions like `calc` and `ceil`.",
        reference:
            Uri.parse("https://sass-lang.com/documentation/modules/math"),
        variables: [
          SassModuleVariable(r"e",
              description: "The value of the mathematical constant **e**."),
          SassModuleVariable(r"pi",
              description: "The value of the mathematical constant **π**."),
        ],
        functions: [
          SassModuleFunction(
            "ceil",
            description: r"Rounds up to the nearest whole number.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "clamp",
            description:
                r"Restricts $number to the range between `$min` and `$max`. If `$number` is less than `$min` this returns `$min`, and if it's greater than `$max` this returns `$max`.",
            signature: r"($min, $number, $max)",
            parameterSnippet: r"${1:min}, ${2:number}, ${3:max}",
            returns: "number",
          ),
          SassModuleFunction(
            "floor",
            description: r"Rounds down to the nearest whole number.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "max",
            description: r"Returns the highest of two or more numbers.",
            signature: r"($number...)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "min",
            description: r"Returns the lowest of two or more numbers.",
            signature: r"($number...)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "round",
            description: r"Rounds to the nearest whole number.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "abs",
            description: r"Returns the absolute value of `$number`.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "hypot",
            description:
                r"Returns the length of the n-dimensional vector that has components equal to each $number. For example, for three numbers a, b, and c, this returns the square root of a² + b² + c².",
            signature: r"($number...)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "log",
            description:
                r"Returns the logarithm of `$number` with respect to `$base`. If `$base` is `null`, the natural log is calculated.",
            signature: r"($number, $base: null)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "pow",
            description:
                r"Raises `$base` to the power of `$exponent`. Both values must be unitless.",
            signature: r"($base, $exponent)",
            parameterSnippet: r"${1:base}, ${2:exponent}",
            returns: "number",
          ),
          SassModuleFunction(
            "sqrt",
            description:
                r"Returns the square root of `$number`. `$number` must be unitless.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "cos",
            description:
                r"Returns the cosine of `$number`. `$number` must be an angle or unitless.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "sin",
            description:
                r"Returns the sine of `$number`. `$number` must be an angle or unitless.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "tan",
            description:
                r"Returns the tangent of `$number`. `$number` must be an angle or unitless.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "acos",
            description:
                r"Returns the arccosine of `$number` in deg. `$number` must be unitless.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "asin",
            description:
                r"Returns the arcsine of `$number` in deg. `$number` must be unitless.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "atan",
            description:
                r"Returns the arctangent of `$number` in deg. `$number` must be unitless.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "atan2",
            description:
                r"Returns the 2-argument arctangent of `$y` and `$x` in deg. `$y` and `$x` must have compatible units or be unitless.",
            signature: r"($y, $x)",
            parameterSnippet: r"${1:y}, ${2:x}",
            returns: "number",
          ),
          SassModuleFunction(
            "compatible",
            description:
                r"Returns whether `$number1` and `$number2` have compatible units.",
            signature: r"($number1, $number2)",
            parameterSnippet: r"${1:number1}, ${2:number2}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "is-unitless",
            description: r"Returns true if `$number` has no units.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "unit",
            description:
                r"Returns a string representation of `$number`'s units.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "string",
          ),
          SassModuleFunction(
            "div",
            description: r"Divides `$number1` by `$number2`.",
            signature: r"($number1, $number2)",
            parameterSnippet: r"${1:number1}, ${2:number2}",
            returns: "number",
          ),
          SassModuleFunction(
            "percentage",
            description: r"Converts a unitless `$number` to a percentage.",
            signature: r"($number)",
            parameterSnippet: r"${1:number}",
            returns: "number",
          ),
          SassModuleFunction(
            "random",
            description:
                r"Returns a random decimal number between **0** and **1**, or a random whole number between **1** and `$limit`.",
            signature: r"($limit: null)",
            parameterSnippet: r"${1:limit}",
            returns: "number",
          ),
        ]),
    SassModule("sass:meta",
        description: "Access to the inner workings of Sass.",
        reference:
            Uri.parse("https://sass-lang.com/documentation/modules/meta"),
        functions: [
          SassModuleFunction("load-css",
              description:
                  r"Load the module at $url and include its CSS as if it were written as the contents of this mixin. The optional $with parameter configures the modules. It must be a map from variable names (without $) to the values of those variables.",
              signature: r"($url, $with: null)",
              parameterSnippet: r"${1:url}",
              returns: "void"),
          SassModuleFunction(
            "calc-args",
            description: r"Returns the arguments for the given calculation.",
            signature: r"($calc)",
            parameterSnippet: r"${1:calc}",
            returns: "list",
          ),
          SassModuleFunction(
            "calc-name",
            description: r"Returns the name of the given calculation.",
            signature: r"($calc)",
            parameterSnippet: r"${1:calc}",
            returns: "string",
          ),
          SassModuleFunction(
            "call",
            description:
                "Invokes \$function with \$args and returns the result.\n\nThe \$function should be a function returned by meta.get-function().",
            signature: r"($function, $args...)",
            parameterSnippet: r"${1:function}, ${2:args}",
            returns: "T",
          ),
          SassModuleFunction(
            "content-exists",
            description:
                "Returns whether the current mixin was passed a @content block.\n\nThrows if called outside of a mixin.",
            signature: r"()",
            parameterSnippet: r"",
            returns: "boolean",
          ),
          SassModuleFunction(
            "feature-exists",
            description:
                r"Returns whether the current Sass implementation supports the given feature.",
            signature: r"($feature)",
            parameterSnippet: r"${1:feature}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "function-exists",
            description:
                r"Returns whether a function named $name is defined, either as a built-in function or a user-defined function.",
            signature: r"($name)",
            parameterSnippet: r"${1:name}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "get-function",
            description:
                "Returns the function named \$name.\n\nIf \$module is null, this returns the function named \$name without a namespace. Otherwise, \$module must be a string matching the namespace of a @use rule in the current file.\n\nBy default, this throws an error if \$name doesn't refer to a Sass function. However, if \$css is true, it instead returns a plain CSS function.\n\nThe returned function can be called using meta.call().",
            signature: r"($name, $css: false, $module: null)",
            parameterSnippet: r"${1:name}",
            returns: "function",
          ),
          SassModuleFunction(
            "global-variable-exists",
            description:
                "Returns whether a global variable named \$name (without the \$) exists.\n\nIf \$module is null, this returns whether a variable named \$name without a namespace exists. Otherwise, \$module must be a string matching the namespace of a @use rule in the current file, in which case this returns whether that module has a variable named \$name.",
            signature: r"($name, $module: null)",
            parameterSnippet: r"${1:name}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "inspect",
            description:
                "Returns a string representation of \$value.\n\nThis function is intended for debugging.",
            signature: r"($value)",
            parameterSnippet: r"${1:value}",
            returns: "string",
          ),
          SassModuleFunction(
            "keywords",
            description:
                "Returns the keywords passed to a mixin or function that takes arbitrary arguments. The \$args argument must be an argument list.\n\nThe keywords are returned as a map from argument names as unquoted strings (not including \$) to the values of those arguments.",
            signature: r"($args)",
            parameterSnippet: r"${1:args}",
            returns: "map",
          ),
          SassModuleFunction(
            "mixin-exists",
            description:
                "Returns whether a mixin named \$name exists.\n\nIf \$module is null, this returns whether a mixin named \$name without a namespace exists. Otherwise, \$module must be a string matching the namespace of a @use rule in the current file, in which case this returns whether that module has a mixin named \$name.",
            signature: r"($name, $module: null)",
            parameterSnippet: r"${1:name}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "module-functions",
            description:
                "Returns all the functions defined in a module, as a map from function names to function values.\n\nThe \$module parameter must be a string matching the namespace of a @use rule in the current file.",
            signature: r"($module)",
            parameterSnippet: r"${1:module}",
            returns: "map",
          ),
          SassModuleFunction(
            "module-variables",
            description:
                "Returns all the variables defined in a module, as a map from variable names (without \$) to the values of those variables.\n\nThe \$module parameter must be a string matching the namespace of a @use rule in the current file.",
            signature: r"($module)",
            parameterSnippet: r"${1:module}",
            returns: "map",
          ),
          SassModuleFunction(
            "type-of",
            description: r"Returns the type of $value.",
            signature: r"($value)",
            parameterSnippet: r"${1:value}",
            returns: "string",
          ),
          SassModuleFunction(
            "variable-exists",
            description:
                r"Returns whether a variable named $name (without the $) exists in the current scope.",
            signature: r"($name)",
            parameterSnippet: r"${1:name}",
            returns: "string",
          ),
        ]),
    SassModule("sass:selector",
        description: "Access to the Sass selector engine.",
        reference:
            Uri.parse("https://sass-lang.com/documentation/modules/selector"),
        functions: [
          SassModuleFunction(
            "is-superselector",
            description:
                r"Returns whether the selector `$super` matches all the elements that the selector `$sub` matches.",
            signature: r"($super, $sub)",
            parameterSnippet: r"${1:super}, ${2:sub}",
            returns: "boolean",
          ),
          SassModuleFunction(
            "append",
            description:
                "Combines `\$selectors` without descendant combinators — that is, without whitespace between them.\n\nIf any selector in `\$selectors` is a selector list, each complex selector is combined separately.\n\nThe `\$selectors` may contain placeholder selectors, but not parent selectors.",
            signature: r"($selectors...)",
            parameterSnippet: r"${1:selectors}",
            returns: "selector",
          ),
          SassModuleFunction(
            "extend",
            description: r"Extends `$selector` as with the `@extend` rule.",
            signature: r"($selector, $extendee, $extender)",
            parameterSnippet: r"${1:selector}, ${2:extendee}, ${3:extender}",
            returns: "selector",
          ),
          SassModuleFunction(
            "nest",
            description:
                r"Combines `$selectors` as though they were nested within one another in the stylesheet.",
            signature: r"($selectors...)",
            parameterSnippet: r"${1:selectors}",
            returns: "selector",
          ),
          SassModuleFunction(
            "parse",
            description: r"Returns `$selector` in the selector value format.",
            signature: r"($selector)",
            parameterSnippet: r"${1:selector}",
            returns: "selector",
          ),
          SassModuleFunction(
            "replace",
            description:
                r"Returns a copy of `$selector` with all instances of $original replaced by `$replacement`. Uses the same intelligent unification as `@extend`.",
            signature: r"($selector, $original, $replacement)",
            parameterSnippet: r"${1:selector}, ${2:original}, ${3:replacement}",
            returns: "selector",
          ),
          SassModuleFunction(
            "unify",
            description:
                r"Returns a selector that matches only elements matched by both `$selector1` and `$selector2`, or `null` if there is no overlap.",
            signature: r"($selector1, $selector2)",
            parameterSnippet: r"${1:selector1}, ${2:selector2}",
            returns: "selector",
          ),
          SassModuleFunction(
            "simple-selectors",
            description:
                "Returns a list of simple selectors in `\$selector`.\n\n`\$selector` must be a single string that contains a compound selector. This means it may not contain combinators (including spaces) or commas.\n\nThe returned list is comma-separated, and the simple selectors are unquoted strings.",
            signature: r"($selector)",
            parameterSnippet: r"${1:selector}",
            returns: "list",
          ),
        ]),
    SassModule("sass:string",
        description: "Combine, split and search strings.",
        reference:
            Uri.parse("https://sass-lang.com/documentation/modules/string"),
        functions: [
          SassModuleFunction(
            "quote",
            description: r"Returns `$string` as a quoted string.",
            signature: r"($string)",
            parameterSnippet: r"${1:string}",
            returns: "string",
          ),
          SassModuleFunction(
            "index",
            description:
                "Returns the first index of `\$substring` in `\$string`, or `null` if the substring is not found.\n\nNote that the index **1** indicates the first character of `\$string` in Sass.",
            signature: r"($string, $substring)",
            parameterSnippet: r"${1:string}, ${2:substring}",
            returns: "number",
          ),
          SassModuleFunction(
            "insert",
            description:
                "Returns a copy of `\$string` with `\$insert` inserted at `\$index`.\n\nNote that the index **1** indicates the first character of `\$string` in Sass.",
            signature: r"($string, $insert, $index)",
            parameterSnippet: r"${1:string}, ${2:insert}, ${3:index}",
            returns: "string",
          ),
          SassModuleFunction(
            "length",
            description: r"Returns the number of characters in `$string`.",
            signature: r"($string)",
            parameterSnippet: r"${1:string}",
            returns: "number",
          ),
          SassModuleFunction(
            "slice",
            description:
                "Returns the slice of `\$string` starting at index `\$start-at` and ending at index `\$end-at` (both inclusive).\n\nNote that the index **1** indicates the first character of `\$string` in Sass.",
            signature: r"($string, $start-at, $end-at: -1)",
            parameterSnippet: r"${1:string}, ${2:start-at}",
            returns: "string",
          ),
          SassModuleFunction(
            "split",
            description:
                "Returns a bracketed, comma-separated list of substrings of `\$string` that are separated by `\$separator`. The `\$separator`s aren't included in these substrings.\n\nIf `\$limit` is a number 1 or higher, this splits on at most that many `\$separator`s (and so returns at most `\$limit` + 1 strings). The last substring contains the rest of the string, including any remaining `\$separator`s.",
            signature: r"($string, $separator, $limit: null)",
            parameterSnippet: r"${1:string}, ${2:separator}",
            returns: "list",
          ),
          SassModuleFunction(
            "to-upper-case",
            description:
                r"Returns a copy of `$string` with the ASCII letters converted to upper case.",
            signature: r"($string)",
            parameterSnippet: r"${1:string}",
            returns: "string",
          ),
          SassModuleFunction(
            "to-lower-case",
            description:
                r"Returns a copy of `$string` with the ASCII letters converted to lower case.",
            signature: r"($string)",
            parameterSnippet: r"${1:string}",
            returns: "string",
          ),
          SassModuleFunction(
            "unique-id",
            description:
                r"Returns a randomly-generated unquoted string that's guaranteed to be a valid CSS identifier and to be unique within the current Sass compilation.",
            signature: r"()",
            parameterSnippet: "",
            returns: "string",
          ),
          SassModuleFunction(
            "unquote",
            description:
                r"Returns `$string` as an unquoted string. This can produce strings that are _not_ valid CSS, so use with caution.",
            signature: r"($string)",
            parameterSnippet: r"${1:string}",
            returns: "string",
          ),
        ])
  ];
}
