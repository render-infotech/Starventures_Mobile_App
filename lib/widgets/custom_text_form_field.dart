  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:starcapitalventures/app_export/app_export.dart';
  class CustomTextFormField extends StatelessWidget {


    CustomTextFormField({

      Key? key,
      this.onChanged,
      this.alignment,
      this.width,
      this.margin,
      this.controller,
      this.focusNode,
      this.autofocus = true,
      this.textStyle,
      this.obscureText = false,
      this.textInputAction = TextInputAction.next,
      this.textInputType = TextInputType.text,
      this.maxLines,
      this.hintText,
      this.hintStyle,
      this.prefix,
      this.prefixConstraints,
      this.suffix,
      this.suffixConstraints,
      this.fillColor,
      this.filled = false,
      this.contentPadding,
      this.defaultBorderDecoration,
      this.enabledBorderDecoration,
      this.focusedBorderDecoration,
      this.disabledBorderDecoration,
      this.validator,
      this.inputFormatters,  // Add inputFormatters here
      this.readOnly = false,
      this.initialValue,  // Add here
      this.maxLength
    }) : super(key: key);
    final String? initialValue;
    final Alignment? alignment;
    final double? width;
    final EdgeInsetsGeometry? margin;
    final TextEditingController? controller;
    final FocusNode? focusNode;
    final bool? autofocus;
    final TextStyle? textStyle;
    final bool? obscureText;
    final TextInputAction? textInputAction;
    final TextInputType? textInputType;
    final int? maxLines;
    final String? hintText;
    final TextStyle? hintStyle;
    final Widget? prefix;
    final BoxConstraints? prefixConstraints;
    final Widget? suffix;
    final BoxConstraints? suffixConstraints;
    final Color? fillColor;
    final bool? filled;
    final EdgeInsets? contentPadding;
    final InputBorder? defaultBorderDecoration;
    final InputBorder? enabledBorderDecoration;
    final InputBorder? focusedBorderDecoration;
    final InputBorder? disabledBorderDecoration;
    final FormFieldValidator<String>? validator;
    final List<TextInputFormatter>? inputFormatters;  // Declare the inputFormatters here
    final bool readOnly;
    final int? maxLength; // 👈 Add this field
    final ValueChanged<String>? onChanged; // <-- NEW

    @override
    Widget build(BuildContext context) {
      return alignment != null
          ? Align(
        alignment: alignment ?? Alignment.center,
        child: textFormFieldWidget(context),  // pass context here
      )
          : textFormFieldWidget(context);          // pass context here too
    }

    Widget textFormFieldWidget(BuildContext context) => Container(
      width: width ?? double.maxFinite,
      margin: margin,
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: appTheme.theme,
            selectionColor: appTheme.theme.withOpacity(0.4),
            selectionHandleColor: appTheme.theme,
          ),
        ),
        child: TextFormField(
          controller: controller,
          style: textStyle,
          obscureText: obscureText!,
          textInputAction: textInputAction,
          keyboardType: textInputType,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          decoration: decoration,
          validator: validator,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
        ),
      ),
    );

    InputDecoration get decoration => InputDecoration(
      hintText: hintText ?? "",
      hintStyle: hintStyle,
      prefixIcon: prefix,
      prefixIconConstraints: prefixConstraints,
      suffixIcon: suffix,
      suffixIconConstraints: suffixConstraints,
      fillColor: fillColor,
      filled: filled,
      isDense: true,
      counterText: "", // 👈 Hides the counter below the text field

      contentPadding: contentPadding,
      border: defaultBorderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getHorizontalSize(
                14.00,
              ),
            ),
            borderSide: BorderSide(
              color: appTheme.blueGray10001,
              width: 1,
            ),
          ),
      enabledBorder: enabledBorderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getHorizontalSize(
                14.00,
              ),
            ),
            borderSide: BorderSide(
              color: appTheme.blueGray10001,
              width: 1,
            ),
          ),
      focusedBorder: focusedBorderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getHorizontalSize(
                14.00,
              ),
            ),
            borderSide: BorderSide(
              color: appTheme.blueGray10001,
              width: 1,
            ),
          ),
      disabledBorder: disabledBorderDecoration ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getHorizontalSize(
                14.00,
              ),
            ),
            borderSide: BorderSide(
              color: appTheme.blueGray10001,
              width: 1,
            ),
          ),
    );

  }

  /// Extension on [CustomTextFormField] to facilitate inclusion of all types of border style etc
  extension TextFormFieldStyleHelper on CustomTextFormField {
    static OutlineInputBorder get outlineRed600 => OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getHorizontalSize(
              14.00,
            ),
          ),
          borderSide: BorderSide(
            color: appTheme.red600,
            width: 1,
          ),
        );
    static OutlineInputBorder get fillLightgreen50 => OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getHorizontalSize(
              13.00,
            ),
          ),
          borderSide: BorderSide.none,
        );
  }
