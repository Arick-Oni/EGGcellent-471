import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';

class CustomDropdown extends StatefulWidget {
  final List list;
  final double height;
  final TextStyle? textStyle;
  final String hint;
  final double? width;
  final Color? dropdownColor;
  final Color? bcolor;
  final double? iconSize;
  final double? radius;
  final double? hp;
  final bool? icon;
  final Function(String?)? onChanged;

  const CustomDropdown({
    super.key,
    this.textStyle,
    this.hp,
    this.radius,
    this.icon,
    this.bcolor,
    this.iconSize,
    this.dropdownColor,
    required this.list,
    required this.height,
    required this.hint,
    this.width,
    this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String selectData = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: widget.height,
      width: widget.width ?? width(context),
      decoration: shadowDecoration(
        widget.radius ?? 10,
        0,
        widget.dropdownColor ?? tfColor,
        bcolor: widget.bcolor ?? normalGray,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.hp ?? 15),
        child: SizedBox(
          height: height(context) * 0.04,
          child: Row(
            children: [
              widget.icon == true
                  ? Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.calendar_month,
                    size: 15,
                    color: darkGray,
                  ),
                )

              )
                  : addHorizontalySpace(0),
              Expanded(
                child: DropdownButton(
                  icon: Icon(
                    CupertinoIcons.chevron_down,
                    size: widget.iconSize ?? 18,
                    color: gray,
                  ),
                  hint: Text(
                    selectData.isEmpty ? widget.hint : selectData,
                    style: widget.textStyle ??
                        bodyText16normal(color: darkGray),
                  ),
                  style: bodyText15normal(color: black),
                  dropdownColor: white,
                  underline: const SizedBox(),
                  isExpanded: true,
                  items: widget.list.map((e) {
                    return DropdownMenuItem(
                      value: e.toString(),
                      child: Text(e.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectData = value ?? "";
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
