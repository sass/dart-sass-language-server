import 'package:sass_language_services/src/css/css_color_function.dart';
import 'package:sass_language_services/src/css/css_named_color.dart';
import 'package:sass_language_services/src/css/css_data_generated.dart';
import 'package:sass_language_services/src/css/css_function.dart';
import 'package:sass_language_services/src/css/css_keyword.dart';

import 'css_at_directive.dart';
import 'css_property.dart';
import 'css_pseudo_class.dart';
import 'css_pseudo_element.dart';
import 'css_units.dart';
import 'element_selectors.dart';

/// Documentation and API reference used for hover information and completions.
///
/// See also [SassData].
class CssData extends CssDataGenerated {
  final _propertiesSet = <String, CssProperty>{};
  final _atDirectivesSet = <String, CssAtDirective>{};
  final _pseudoClassesSet = <String, CssPseudoClass>{};
  final _pseudoElementsSet = <String, CssPseudoElement>{};

  final cssUnits = CssUnits();
  final elementSelectors = ElementSelectors();

  final basicShapeFunctions = [
    CssFunction("circle()", "Defines a circle."),
    CssFunction("ellipse()", "Defines an ellipse."),
    CssFunction("inset()", "Defines an inset rectangle."),
    CssFunction("polygon()", "Defines a polygon."),
  ];

  final imageFunctions = [
    CssFunction("url()", "Reference an image file by URL"),
    CssFunction("image()", "Provide image fallbacks and annotations."),
    CssFunction("image-set()",
        "Provide multiple resolutions of an image and const the UA decide which is most appropriate in a given situation."),
    CssFunction("element()", "Use an element in the document as an image."),
    CssFunction("cross-fade()",
        "Indicates the two images to be combined and how far along in the transition the combination is."),
    CssFunction("linear-gradient()",
        "A linear gradient is created by specifying a straight gradient line, and then several colors placed along that line."),
    CssFunction("repeating-linear-gradient()",
        "Same as linear-gradient, except the color-stops are repeated infinitely in both directions, with their positions shifted by multiples of the difference between the last specified color-stop’s position and the first specified color-stop’s position."),
    CssFunction("radial-gradient()",
        "Colors emerge from a single point and smoothly spread outward in a circular or elliptical shape."),
    CssFunction("repeating-radial-gradient()",
        "Same as radial-gradient, except the color-stops are repeated infinitely in both directions, with their positions shifted by multiples of the difference between the last specified color-stop’s position and the first specified color-stop’s position."),
  ];

  final transitionTimingFunctions = [
    CssFunction("ease", "Equivalent to cubic-bezier(0.25, 0.1, 0.25, 1.0)."),
    CssFunction("ease-in", "Equivalent to cubic-bezier(0.42, 0, 1.0, 1.0)."),
    CssFunction(
        "ease-in-out", "Equivalent to cubic-bezier(0.42, 0, 0.58, 1.0)."),
    CssFunction("ease-out", "Equivalent to cubic-bezier(0, 0, 0.58, 1.0)."),
    CssFunction("linear", "Equivalent to cubic-bezier(0.0, 0.0, 1.0, 1.0)."),
    CssFunction("step-end", "Equivalent to steps(1, end)."),
    CssFunction("step-start", "Equivalent to steps(1, start)."),
    CssFunction("steps()",
        "The first parameter specifies the number of intervals in the function. The second parameter, which is optional, is either the value “start” or “end”."),
    CssFunction("cubic-bezier()",
        "Specifies a cubic-bezier curve. The four values specify points P1 and P2  of the curve as (x1, y1, x2, y2)."),
    CssFunction(
        "cubic-bezier(0.6, -0.28, 0.735, 0.045)", "Ease-in Back. Overshoots."),
    CssFunction("cubic-bezier(0.68, -0.55, 0.265, 1.55)",
        "Ease-in-out Back. Overshoots."),
    CssFunction("cubic-bezier(0.175, 0.885, 0.32, 1.275)",
        "Ease-out Back. Overshoots."),
    CssFunction("cubic-bezier(0.6, 0.04, 0.98, 0.335)",
        "Ease-in Circular. Based on half circle."),
    CssFunction("cubic-bezier(0.785, 0.135, 0.15, 0.86)",
        "Ease-in-out Circular. Based on half circle."),
    CssFunction("cubic-bezier(0.075, 0.82, 0.165, 1)",
        "Ease-out Circular. Based on half circle."),
    CssFunction("cubic-bezier(0.55, 0.055, 0.675, 0.19)",
        "Ease-in Cubic. Based on power of three."),
    CssFunction("cubic-bezier(0.645, 0.045, 0.355, 1)",
        "Ease-in-out Cubic. Based on power of three."),
    CssFunction("cubic-bezier(0.215, 0.610, 0.355, 1)",
        "Ease-out Cubic. Based on power of three."),
    CssFunction("cubic-bezier(0.95, 0.05, 0.795, 0.035)",
        "Ease-in Exponential. Based on two to the power ten."),
    CssFunction("cubic-bezier(1, 0, 0, 1)",
        "Ease-in-out Exponential. Based on two to the power ten."),
    CssFunction("cubic-bezier(0.19, 1, 0.22, 1)",
        "Ease-out Exponential. Based on two to the power ten."),
    CssFunction("cubic-bezier(0.47, 0, 0.745, 0.715)", "Ease-in Sine."),
    CssFunction("cubic-bezier(0.445, 0.05, 0.55, 0.95)", "Ease-in-out Sine."),
    CssFunction("cubic-bezier(0.39, 0.575, 0.565, 1)", "Ease-out Sine."),
    CssFunction("cubic-bezier(0.55, 0.085, 0.68, 0.53)",
        "Ease-in Quadratic. Based on power of two."),
    CssFunction("cubic-bezier(0.455, 0.03, 0.515, 0.955)",
        "Ease-in-out Quadratic. Based on power of two."),
    CssFunction("cubic-bezier(0.25, 0.46, 0.45, 0.94)",
        "Ease-out Quadratic. Based on power of two."),
    CssFunction("cubic-bezier(0.895, 0.03, 0.685, 0.22)",
        "Ease-in Quartic. Based on power of four."),
    CssFunction("cubic-bezier(0.77, 0, 0.175, 1)",
        "Ease-in-out Quartic. Based on power of four."),
    CssFunction("cubic-bezier(0.165, 0.84, 0.44, 1)",
        "Ease-out Quartic. Based on power of four."),
    CssFunction("cubic-bezier(0.755, 0.05, 0.855, 0.06)",
        "Ease-in Quintic. Based on power of five."),
    CssFunction("cubic-bezier(0.86, 0, 0.07, 1)",
        "Ease-in-out Quintic. Based on power of five."),
    CssFunction("cubic-bezier(0.23, 1, 0.320, 1)",
        "Ease-out Quintic. Based on power of five."),
  ];

  final globalFunctions = [
    CssFunction("var()", "Evaluates the value of a custom variable."),
    CssFunction("calc()",
        "Evaluates an mathematical expression. The following operators can be used: + - * /."),
  ];

  final colorFunctions = [
    CssColorFunction(
      "rgb",
      r"rgb($red, $green, $blue)",
      r"rgb(${1:red}, ${2:green}, ${3:blue})",
      "Creates a Color from red, green, and blue values.",
    ),
    CssColorFunction(
      "rgba",
      r"rgba($red, $green, $blue, $alpha)",
      r"rgba(${1:red}, ${2:green}, ${3:blue}, ${4:alpha})",
      "Creates a Color from red, green, blue, and alpha values.",
    ),
    CssColorFunction(
      "rgb relative",
      r"rgb(from $color $red $green $blue)",
      r"rgb(from ${1:color} ${2:r} ${3:g} ${4:b})",
      "Creates a Color from the red, green, and blue values of another Color.",
    ),
    CssColorFunction(
      "hsl",
      r"hsl($hue, $saturation, $lightness)",
      r"hsl(${1:hue}, ${2:saturation}, ${3:lightness})",
      "Creates a Color from hue, saturation, and lightness values.",
    ),
    CssColorFunction(
      "hsla",
      r"hsla($hue, $saturation, $lightness, $alpha)",
      r"hsla(${1:hue}, ${2:saturation}, ${3:lightness}, ${4:alpha})",
      "Creates a Color from hue, saturation, lightness, and alpha values.",
    ),
    CssColorFunction(
      "hsl relative",
      r"hsl(from $color $hue $saturation $lightness)",
      r"hsl(from ${1:color} ${2:h} ${3:s} ${4:l})",
      "Creates a Color from the hue, saturation, and lightness values of another Color.",
    ),
    CssColorFunction(
      "hwb",
      r"hwb($hue $white $black)",
      r"hwb(${1:hue} ${2:white} ${3:black})",
      "Creates a Color from hue, white, and black values.",
    ),
    CssColorFunction(
      "hwb relative",
      r"hwb(from $color $hue $white $black)",
      r"hwb(from ${1:color} ${2:h} ${3:w} ${4:b})",
      "Creates a Color from the hue, white, and black values of another Color.",
    ),
    CssColorFunction(
      "lab",
      r"lab($lightness $a $b)",
      r"lab(${1:lightness} ${2:a} ${3:b})",
      "Creates a Color from lightness, a, and b values.",
    ),
    CssColorFunction(
      "lab relative",
      r"lab(from $color $lightness $a $b)",
      r"lab(from ${1:color} ${2:l} ${3:a} ${4:b})",
      "Creates a Color from the lightness, a, and b values of another Color.",
    ),
    CssColorFunction(
      "oklab",
      r"oklab($lightness $a $b)",
      r"oklab(${1:lightness} ${2:a} ${3:b})",
      "Creates a Color from lightness, a, and b values.",
    ),
    CssColorFunction(
      "oklab relative",
      r"oklab(from $color $lightness $a $b)",
      r"oklab(from ${1:color} ${2:l} ${3:a} ${4:b})",
      "Creates a Color from the lightness, a, and b values of another Color.",
    ),
    CssColorFunction(
      "lch",
      r"lch($lightness $chroma $hue)",
      r"lch(${1:lightness} ${2:chroma} ${3:hue})",
      "Creates a Color from lightness, chroma, and hue values.",
    ),
    CssColorFunction(
      "lch relative",
      r"lch(from $color $lightness $chroma $hue)",
      r"lch(from ${1:color} ${2:l} ${3:c} ${4:h})",
      "Creates a Color from the lightness, chroma, and hue values of another Color.",
    ),
    CssColorFunction(
      "oklch",
      r"oklch($lightness $chroma $hue)",
      r"oklch(${1:lightness} ${2:chroma} ${3:hue})",
      "Creates a Color from lightness, chroma, and hue values.",
    ),
    CssColorFunction(
      "oklch relative",
      r"oklch(from $color $lightness $chroma $hue)",
      r"oklch(from ${1:color} ${2:l} ${3:c} ${4:h})",
      "Creates a Color from the lightness, chroma, and hue values of another Color.",
    ),
    CssColorFunction(
      "color",
      r"color($color-space $red $green $blue)",
      r"color(${1|srgb,srgb-linear,display-p3,a98-rgb,prophoto-rgb,rec2020,xyx,xyz-d50,xyz-d65|} ${2:red} ${3:green} ${4:blue})",
      "Creates a Color in a specific color space from red, green, and blue values.",
    ),
    CssColorFunction(
      "color relative",
      r"color(from $color $color-space $red $green $blue)",
      r"color(from ${1:color} ${2|srgb,srgb-linear,display-p3,a98-rgb,prophoto-rgb,rec2020,xyx,xyz-d50,xyz-d65|} ${3:r} ${4:g} ${5:b})",
      "Creates a Color in a specific color space from the red, green, and blue values of another Color.",
    ),
    CssColorFunction(
      "color-mix",
      r"color-mix(in $color-space, $color $percentage, $color $percentage)",
      r"color-mix(in ${1|srgb,srgb-linear,lab,oklab,xyz,xyz-d50,xyz-d65|}, ${3:color} ${4:percentage}, ${5:color} ${6:percentage})",
      "Mix two colors together in a rectangular color space.",
    ),
    CssColorFunction(
      "color-mix hue",
      r"color-mix(in $color-space $interpolation-method hue, $color $percentage, $color $percentage)",
      r"color-mix(in ${1|hsl,hwb,lch,oklch|} ${2|shorter hue,longer hue,increasing hue,decreasing hue|}, ${3:color} ${4:percentage}, ${5:color} ${6:percentage})",
      "Mix two colors together in a polar color space.",
    ),
  ];

  final colorKeywords = [
    CssKeyword("currentColor",
        "The value of the 'color' property. The computed value of the 'currentColor' keyword is the computed value of the 'color' property. If the 'currentColor' keyword is set on the 'color' property itself, it is treated as 'color:inherit' at parse time."),
    CssKeyword("transparent",
        "Fully transparent. This keyword can be considered a shorthand for rgba(0,0,0,0) which is its computed value."),
  ];

  final namedColors = [
    CssNamedColor("aliceblue", "#f0f8ff"),
    CssNamedColor("antiquewhite", "#faebd7"),
    CssNamedColor("aqua", "#00ffff"),
    CssNamedColor("aquamarine", "#7fffd4"),
    CssNamedColor("azure", "#f0ffff"),
    CssNamedColor("beige", "#f5f5dc"),
    CssNamedColor("bisque", "#ffe4c4"),
    CssNamedColor("black", "#000000"),
    CssNamedColor("blanchedalmond", "#ffebcd"),
    CssNamedColor("blue", "#0000ff"),
    CssNamedColor("blueviolet", "#8a2be2"),
    CssNamedColor("brown", "#a52a2a"),
    CssNamedColor("burlywood", "#deb887"),
    CssNamedColor("cadetblue", "#5f9ea0"),
    CssNamedColor("chartreuse", "#7fff00"),
    CssNamedColor("chocolate", "#d2691e"),
    CssNamedColor("coral", "#ff7f50"),
    CssNamedColor("cornflowerblue", "#6495ed"),
    CssNamedColor("cornsilk", "#fff8dc"),
    CssNamedColor("crimson", "#dc143c"),
    CssNamedColor("cyan", "#00ffff"),
    CssNamedColor("darkblue", "#00008b"),
    CssNamedColor("darkcyan", "#008b8b"),
    CssNamedColor("darkgoldenrod", "#b8860b"),
    CssNamedColor("darkgray", "#a9a9a9"),
    CssNamedColor("darkgrey", "#a9a9a9"),
    CssNamedColor("darkgreen", "#006400"),
    CssNamedColor("darkkhaki", "#bdb76b"),
    CssNamedColor("darkmagenta", "#8b008b"),
    CssNamedColor("darkolivegreen", "#556b2f"),
    CssNamedColor("darkorange", "#ff8c00"),
    CssNamedColor("darkorchid", "#9932cc"),
    CssNamedColor("darkred", "#8b0000"),
    CssNamedColor("darksalmon", "#e9967a"),
    CssNamedColor("darkseagreen", "#8fbc8f"),
    CssNamedColor("darkslateblue", "#483d8b"),
    CssNamedColor("darkslategray", "#2f4f4f"),
    CssNamedColor("darkslategrey", "#2f4f4f"),
    CssNamedColor("darkturquoise", "#00ced1"),
    CssNamedColor("darkviolet", "#9400d3"),
    CssNamedColor("deeppink", "#ff1493"),
    CssNamedColor("deepskyblue", "#00bfff"),
    CssNamedColor("dimgray", "#696969"),
    CssNamedColor("dimgrey", "#696969"),
    CssNamedColor("dodgerblue", "#1e90ff"),
    CssNamedColor("firebrick", "#b22222"),
    CssNamedColor("floralwhite", "#fffaf0"),
    CssNamedColor("forestgreen", "#228b22"),
    CssNamedColor("fuchsia", "#ff00ff"),
    CssNamedColor("gainsboro", "#dcdcdc"),
    CssNamedColor("ghostwhite", "#f8f8ff"),
    CssNamedColor("gold", "#ffd700"),
    CssNamedColor("goldenrod", "#daa520"),
    CssNamedColor("gray", "#808080"),
    CssNamedColor("grey", "#808080"),
    CssNamedColor("green", "#008000"),
    CssNamedColor("greenyellow", "#adff2f"),
    CssNamedColor("honeydew", "#f0fff0"),
    CssNamedColor("hotpink", "#ff69b4"),
    CssNamedColor("indianred", "#cd5c5c"),
    CssNamedColor("indigo", "#4b0082"),
    CssNamedColor("ivory", "#fffff0"),
    CssNamedColor("khaki", "#f0e68c"),
    CssNamedColor("lavender", "#e6e6fa"),
    CssNamedColor("lavenderblush", "#fff0f5"),
    CssNamedColor("lawngreen", "#7cfc00"),
    CssNamedColor("lemonchiffon", "#fffacd"),
    CssNamedColor("lightblue", "#add8e6"),
    CssNamedColor("lightcoral", "#f08080"),
    CssNamedColor("lightcyan", "#e0ffff"),
    CssNamedColor("lightgoldenrodyellow", "#fafad2"),
    CssNamedColor("lightgray", "#d3d3d3"),
    CssNamedColor("lightgrey", "#d3d3d3"),
    CssNamedColor("lightgreen", "#90ee90"),
    CssNamedColor("lightpink", "#ffb6c1"),
    CssNamedColor("lightsalmon", "#ffa07a"),
    CssNamedColor("lightseagreen", "#20b2aa"),
    CssNamedColor("lightskyblue", "#87cefa"),
    CssNamedColor("lightslategray", "#778899"),
    CssNamedColor("lightslategrey", "#778899"),
    CssNamedColor("lightsteelblue", "#b0c4de"),
    CssNamedColor("lightyellow", "#ffffe0"),
    CssNamedColor("lime", "#00ff00"),
    CssNamedColor("limegreen", "#32cd32"),
    CssNamedColor("linen", "#faf0e6"),
    CssNamedColor("magenta", "#ff00ff"),
    CssNamedColor("maroon", "#800000"),
    CssNamedColor("mediumaquamarine", "#66cdaa"),
    CssNamedColor("mediumblue", "#0000cd"),
    CssNamedColor("mediumorchid", "#ba55d3"),
    CssNamedColor("mediumpurple", "#9370d8"),
    CssNamedColor("mediumseagreen", "#3cb371"),
    CssNamedColor("mediumslateblue", "#7b68ee"),
    CssNamedColor("mediumspringgreen", "#00fa9a"),
    CssNamedColor("mediumturquoise", "#48d1cc"),
    CssNamedColor("mediumvioletred", "#c71585"),
    CssNamedColor("midnightblue", "#191970"),
    CssNamedColor("mintcream", "#f5fffa"),
    CssNamedColor("mistyrose", "#ffe4e1"),
    CssNamedColor("moccasin", "#ffe4b5"),
    CssNamedColor("navajowhite", "#ffdead"),
    CssNamedColor("navy", "#000080"),
    CssNamedColor("oldlace", "#fdf5e6"),
    CssNamedColor("olive", "#808000"),
    CssNamedColor("olivedrab", "#6b8e23"),
    CssNamedColor("orange", "#ffa500"),
    CssNamedColor("orangered", "#ff4500"),
    CssNamedColor("orchid", "#da70d6"),
    CssNamedColor("palegoldenrod", "#eee8aa"),
    CssNamedColor("palegreen", "#98fb98"),
    CssNamedColor("paleturquoise", "#afeeee"),
    CssNamedColor("palevioletred", "#d87093"),
    CssNamedColor("papayawhip", "#ffefd5"),
    CssNamedColor("peachpuff", "#ffdab9"),
    CssNamedColor("peru", "#cd853f"),
    CssNamedColor("pink", "#ffc0cb"),
    CssNamedColor("plum", "#dda0dd"),
    CssNamedColor("powderblue", "#b0e0e6"),
    CssNamedColor("purple", "#800080"),
    CssNamedColor("red", "#ff0000"),
    CssNamedColor("rebeccapurple", "#663399"),
    CssNamedColor("rosybrown", "#bc8f8f"),
    CssNamedColor("royalblue", "#4169e1"),
    CssNamedColor("saddlebrown", "#8b4513"),
    CssNamedColor("salmon", "#fa8072"),
    CssNamedColor("sandybrown", "#f4a460"),
    CssNamedColor("seagreen", "#2e8b57"),
    CssNamedColor("seashell", "#fff5ee"),
    CssNamedColor("sienna", "#a0522d"),
    CssNamedColor("silver", "#c0c0c0"),
    CssNamedColor("skyblue", "#87ceeb"),
    CssNamedColor("slateblue", "#6a5acd"),
    CssNamedColor("slategray", "#708090"),
    CssNamedColor("slategrey", "#708090"),
    CssNamedColor("snow", "#fffafa"),
    CssNamedColor("springgreen", "#00ff7f"),
    CssNamedColor("steelblue", "#4682b4"),
    CssNamedColor("tan", "#d2b48c"),
    CssNamedColor("teal", "#008080"),
    CssNamedColor("thistle", "#d8bfd8"),
    CssNamedColor("tomato", "#ff6347"),
    CssNamedColor("turquoise", "#40e0d0"),
    CssNamedColor("violet", "#ee82ee"),
    CssNamedColor("wheat", "#f5deb3"),
    CssNamedColor("white", "#ffffff"),
    CssNamedColor("whitesmoke", "#f5f5f5"),
    CssNamedColor("yellow", "#ffff00"),
    CssNamedColor("yellowgreen", "#9acd32"),
  ];

  final globalKeywords = [
    CssKeyword("initial",
        "Represents the value specified as the property’s initial value."),
    CssKeyword("inherit",
        "Represents the computed value of the property on the element’s parent."),
    CssKeyword("unset",
        "Acts as either `inherit` or `initial`, depending on whether the property is inherited or not."),
  ];

  final geometryBoxKeywords = [
    CssKeyword("margin-box", "Uses the margin box as reference box."),
    CssKeyword("fill-box", "Uses the object bounding box as reference box."),
    CssKeyword("stroke-box", "Uses the stroke bounding box as reference box."),
    CssKeyword("view-box", "Uses the nearest SVG viewport as reference box."),
  ];

  final boxKeywords = [
    CssKeyword("border-box",
        "The background is painted within (clipped to) the border box."),
    CssKeyword("content-box",
        "The background is painted within (clipped to) the content box."),
    CssKeyword("padding-box",
        "The background is painted within (clipped to) the padding box."),
  ];

  final lineWidthKeywords = ["medium", "thick", "thin"];

  final lineStyleKeywords = [
    CssKeyword("dashed", "A series of square-ended dashes."),
    CssKeyword("dotted", "A series of round dots."),
    CssKeyword(
        "double", "Two parallel solid lines with some space between them."),
    CssKeyword("groove", "Looks as if it were carved in the canvas."),
    CssKeyword("hidden",
        "Same as ‘none’, but has different behavior in the border conflict resolution rules for border-collapsed tables."),
    CssKeyword("inset",
        "Looks as if the content on the inside of the border is sunken into the canvas."),
    CssKeyword("none", "No border. Color and width are ignored."),
    CssKeyword("outset",
        "Looks as if the content on the inside of the border is coming out of the canvas."),
    CssKeyword("ridge", "Looks as if it were coming out of the canvas."),
    CssKeyword("solid", "A single line segment."),
  ];

  final repeateStyleKeywords = [
    CssKeyword("no-repeat", "Placed once and not repeated in this direction."),
    CssKeyword("repeat",
        "Repeated in this direction as often as needed to cover the background painting area."),
    CssKeyword("repeat-x", "Computes to ‘repeat no-repeat’."),
    CssKeyword("repeat-y", "Computes to ‘no-repeat repeat’."),
    CssKeyword("round",
        "Repeated as often as will fit within the background positioning area. If it doesn’t fit a whole number of times, it is rescaled so that it does."),
    CssKeyword("space",
        "Repeated as often as will fit within the background positioning area without being clipped and then the images are spaced out to fill the area."),
  ];

  final positionKeywords = [
    CssKeyword("bottom",
        "Computes to ‘100%’ for the vertical position if one or two values are given, otherwise specifies the bottom edge as the origin for the next offset."),
    CssKeyword("center",
        "Computes to ‘50%’ (‘left 50%’) for the horizontal position if the horizontal position is not otherwise specified, or ‘50%’ (‘top 50%’) for the vertical position if it is."),
    CssKeyword("left",
        "Computes to ‘0%’ for the horizontal position if one or two values are given, otherwise specifies the left edge as the origin for the next offset."),
    CssKeyword("right",
        "Computes to ‘100%’ for the horizontal position if one or two values are given, otherwise specifies the right edge as the origin for the next offset."),
    CssKeyword("top",
        "Computes to ‘0%’ for the vertical position if one or two values are given, otherwise specifies the top edge as the origin for the next offset."),
  ];

  CssData() {
    for (var entry in properties) {
      _propertiesSet[entry.name] = entry;
    }
    for (var entry in atDirectives) {
      _atDirectivesSet[entry.name] = entry;
    }
    for (var entry in pseudoClasses) {
      _pseudoClassesSet[entry.name] = entry;
    }
    for (var entry in pseudoElements) {
      _pseudoElementsSet[entry.name] = entry;
    }
  }

  CssProperty? getProperty(String name) {
    return _propertiesSet[name];
  }

  CssAtDirective? getAtDirective(String name) {
    return _atDirectivesSet[name];
  }

  CssPseudoClass? getPseudoClass(String name) {
    return _pseudoClassesSet[name];
  }

  CssPseudoElement? getPseudoElement(String name) {
    return _pseudoElementsSet[name];
  }
}
