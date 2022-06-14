import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:planter_squared/data/models/garden.dart';
import 'package:planter_squared/data/models/todo.dart';
import 'package:planter_squared/data/providers/authentication.dart';
import 'package:planter_squared/screens/plant_list.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class MaterialSearchBar extends StatefulWidget {
  const MaterialSearchBar({
    Key? key,
    this.backgroundColor,
    this.actionButtonColor,
    this.color,
    this.blurSize,
    required this.hintText,
    required this.onSearchConfirm,
  }) : super(key: key);

  final Color? backgroundColor;
  final Color? actionButtonColor;
  final Color? color;
  final double? blurSize;
  final String hintText;
  final void Function(String searchCriteria) onSearchConfirm;

  @override
  State<MaterialSearchBar> createState() => _MaterialSearchBarState();
}

class _MaterialSearchBarState extends State<MaterialSearchBar> {
  late final TextEditingController _controller;
  bool _isWritting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _actionButton() {
    if (_isWritting) {
      _controller.clear();
      setState(() {
        _isWritting = false;
      });
    }
  }

  void _submit(String text) {
    widget.onSearchConfirm(text);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double bSize = widget.blurSize ?? 10.0;
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.0),
        color: widget.backgroundColor ?? colorScheme.onBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: -bSize,
            blurRadius: bSize,
            offset: Offset(0.0, bSize),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 16.0, top: 11.0),
              alignment: Alignment.topCenter,
              child: TextField(
                controller: _controller,
                onChanged: (text) {
                  if ((_isWritting && text.isEmpty) || (!_isWritting && text.isNotEmpty)) {
                    setState(() {
                      _isWritting = !_isWritting;
                    });
                  }
                },
                onSubmitted: _submit,
                cursorRadius: const Radius.circular(10.0),
                cursorColor: widget.color,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 8.0),
                  isDense: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  alignLabelWithHint: true,
                  hintText: widget.hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 7.0),
            child: IconButton(
              splashRadius: 24.0,
              icon: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: widget.actionButtonColor,
                  borderRadius: BorderRadius.circular(32.0),
                ),
                child: Icon(
                  _isWritting ? Icons.close : Icons.search,
                  size: 20.0,
                ),
              ),
              onPressed: _actionButton,
            ),
          ),
        ],
      ),
    );
  }
}

class FormInputText extends StatefulWidget {
  const FormInputText({
    Key? key,
    required this.controller,
    required this.fieldName,
    this.validators = const [],
    this.textInputType = TextInputType.text,
    this.fieldHint = '',
    this.required = false,
    this.obscureText = false,
    this.autocorrect = false,
    this.showSuggestions = false,
    this.preventWhitespaces = true,
    this.textInputAction = TextInputAction.next,
    this.leading,
  }) : super(key: key);

  final TextEditingController controller;
  final String fieldName;
  final String fieldHint;
  final bool obscureText;
  final bool required;
  final bool autocorrect;
  final bool showSuggestions;
  final bool preventWhitespaces;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final List<FieldValidator> validators;
  final Icon? leading;

  @override
  State<FormInputText> createState() => _FormInputTextState();
}

class _FormInputTextState extends State<FormInputText> {
  late bool _isShowingField;

  @override
  void initState() {
    super.initState();
    _isShowingField = !widget.obscureText;
  }

  void _toggleFieldVisibility() {
    if (widget.obscureText) {
      setState(() {
        _isShowingField = !_isShowingField;
      });
    }
  }

  String? _validator(String? value) {
    if (widget.required && (value == null || value.isEmpty)) {
      return 'Required';
    }
    for (final validator in widget.validators) {
      if (!validator.checker(value)) {
        return validator.message;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,
      obscureText: !_isShowingField,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.showSuggestions,
      inputFormatters: widget.preventWhitespaces ? [FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))] : null,
      validator: _validator,
      decoration: InputDecoration(
          icon: widget.leading,
          labelText: widget.fieldName, //(widget.required ? '* ' : '') + widget.fieldName,
          hintText: widget.fieldHint,
          border: OutlineInputBorder(
            borderSide: Divider.createBorderSide(context, color: theme.dividerColor),
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  splashRadius: Material.defaultSplashRadius * 0.5,
                  onPressed: _toggleFieldVisibility,
                  icon: Icon(_isShowingField ? Icons.visibility : Icons.visibility_off),
                )
              : null),
    );
  }
}

class FieldValidator {
  const FieldValidator({
    required this.checker,
    required this.message,
  });

  final bool Function(String?) checker;
  final String message;
}

class FormTextFieldValidators {
  FormTextFieldValidators._();

  static final emailField = [
    FieldValidator(
      checker: (value) => EmailValidator.validate(value!),
      message: 'Please enter a valid email address',
    ),
  ];

  static final passwordField = [
    FieldValidator(
      checker: (value) => RegExp(r"^.{8,}$").hasMatch(value!),
      message: 'Password must be at least 8 characters long',
    ),
    /*FieldValidator(
      checker: (value) => RegExp(r"(?:.*[A-Z])").hasMatch(value!),
      message: 'Password must contain at least one uppercase letter',
    ),
    FieldValidator(
      checker: (value) => RegExp(r"(?:.*[a-z])").hasMatch(value!),
      message: 'Password must contain at least one lowercase letter',
    ),
    FieldValidator(
      checker: (value) => RegExp(r"(?:.*?[0-9])").hasMatch(value!),
      message: 'Password must contain at least one digit',
    ),
    FieldValidator(
      checker: (value) => RegExp(r"(?:.*?[!@#\$&*~])").hasMatch(value!),
      message: 'Password must contain at least one special character',
    ),*/
  ];
}

class ModalTaskForm extends StatefulWidget {
  const ModalTaskForm({
    Key? key,
    required this.planter,
  }) : super(key: key);

  final Planter planter;

  @override
  State<ModalTaskForm> createState() => _ModalTaskFormState();
}

class _ModalTaskFormState extends State<ModalTaskForm> {
  DateTime? _taskDate;
  final List<bool> _requirementSelection = [false, false, false];
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Add a task',
              style: textTheme.headlineSmall,
            ),
          ),
          Form(
            child: Column(
              children: [
                Column(
                  children: [
                    ToggleButtons(
                        isSelected: _requirementSelection,
                        onPressed: (int index) {
                          setState(
                            () {
                              for (int buttonIndex = 0; buttonIndex < _requirementSelection.length; buttonIndex++) {
                                if (buttonIndex == index) {
                                  _requirementSelection[buttonIndex] = true;
                                } else {
                                  _requirementSelection[buttonIndex] = false;
                                }
                              }
                            },
                          );
                        },
                        children: RequirementType.values
                            .map(
                              (r) => SizedBox(
                                width: 100.0,
                                child: Card(
                                  child: Column(
                                    children: [
                                      Icon(
                                        r.baseIcon,
                                        color: r.color,
                                        size: 48,
                                      ),
                                      Text(r.name, style: textTheme.labelLarge),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList()),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2012),
                                  lastDate: DateTime(2032, 12, 31));
                              TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                              if (date != null || time != null) {
                                setState(() {
                                  _taskDate = date!.add(Duration(hours: time!.hour, minutes: time.minute));
                                });
                              }
                            },
                            child: Text(
                                'Due date: ${_taskDate != null ? DateFormat('yyyy-MM-dd HH:MM').format(_taskDate!) : 'Not set'}'),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FormInputText(
                        controller: _descriptionController,
                        fieldName: 'Description',
                        preventWhitespaces: false,
                        required: false,
                        showSuggestions: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final description = _descriptionController.text;
                        if (_taskDate == null && _requirementSelection.every((element) => !element)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Missing date and requirement'),
                            ),
                          );
                        } else if (_taskDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Missing date'),
                            ),
                          );
                        } else if (_requirementSelection.every((element) => !element)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Missing requirement'),
                            ),
                          );
                        } else {
                          final task = Task(
                            taskId: const Uuid().v1(),
                            planterId: widget.planter.planterId,
                            requirementType: RequirementType.values[_requirementSelection.indexOf(true)],
                            timestamp: Timestamp.fromDate(_taskDate!),
                            description: description.isNotEmpty ? description : null,
                          );
                          Provider.of<Authentication>(context, listen: false)
                              .authUser!
                              .taskDatabase
                              .createEntry(task.json(), id: task.taskId);
                          widget.planter.taskIds.add(task.taskId);
                          Provider.of<Authentication>(context, listen: false)
                              .authUser!
                              .planterDatabase
                              .updateEntry(widget.planter.json(), id: widget.planter.planterId);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Submit task'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModalPlanterForm extends StatefulWidget {
  const ModalPlanterForm({
    Key? key,
    this.plant,
  }) : super(key: key);

  final Plant? plant;

  @override
  State<ModalPlanterForm> createState() => _ModalPlanterFormState();
}

class _ModalPlanterFormState extends State<ModalPlanterForm> {
  Plant? _plant;
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
    _nameController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _searchPlants() async {
    final Plant? plant = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: PlantListScreen(
              goToDetails: false,
            ),
          ),
        ),
      ),
    );
    setState(() {
      _plant = plant;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Add a Planter',
              style: textTheme.headlineSmall,
            ),
          ),
          Form(
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: _plant != null
                          ? PlantListItem(
                              item: _plant!,
                              onTapped: (p) => _searchPlants(),
                              doNavigation: false,
                            )
                          : Row(
                              children: [
                                Expanded(
                                    child: ElevatedButton(
                                  onPressed: _searchPlants,
                                  child: const Text('No Plant selected'),
                                ))
                              ],
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FormInputText(
                        controller: _nameController,
                        fieldName: 'Name',
                        preventWhitespaces: false,
                        required: true,
                        showSuggestions: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FormInputText(
                        controller: _locationController,
                        fieldName: 'Location',
                        preventWhitespaces: false,
                        required: true,
                        showSuggestions: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final name = _nameController.text;
                        final location = _locationController.text;
                        if (name.isNotEmpty && location.isNotEmpty && _plant != null) {
                          Planter planter = Planter(
                            planterId: const Uuid().v1(),
                            plantId: _plant!.pid,
                            name: name,
                            location: location,
                            temperatureRead: 0,
                            lightRead: 0,
                            moistureRead: 0,
                            taskIds: [],
                          );
                          await Provider.of<Authentication>(context, listen: false)
                              .authUser!
                              .planterDatabase
                              .createEntry(planter.json(), id: planter.planterId);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Submit planter'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
