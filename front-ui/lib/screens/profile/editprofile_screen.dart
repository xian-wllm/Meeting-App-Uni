import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:Spark/services/profile_service.dart';

enum ColorEnum {
  Jaune, Bleu, Vert, Rose, Rouge, Violet, Gris
}

enum FaculteEnum {
  SCIENCES, MEDECINE, LETTERS, SOCIETY, ECONOMY, LAW, THEOLOGY, PSYCHOLOGY, TRADUCTION, INSTITUTES
}

enum GenderEnum {
  MALE, FEMALE, ENBY, OTHER
}

enum CenterOfInterestEnum {
  ALCOOL, ALLEMAND, ANGLAIS, ANIMAUX, ARCHEOLOGIE, ARTS_MARTIAUX, BATTELLE, BIOLOGIE, CHIMIE, CINEMA, CLIMAT, CMU, COMPETITION,
  DATCHA, DESSIN, DROIT, ECONOMIE, ESPAGNOL, ESPORT, ETUDES, ETUDIANTS, FESTIVALS, FOOTBALL, FRANCAIS, HANDICAPE, HISTOIRE,
  HOCKEY, INFORMATIQUE, ITALIEN, JEUX_VIDEO, LANGUES_ETRANGERES, LETTRES, MALE_ALPHA, MATHEMATIQUES, MEDECINE, MONTAGNE,
  MUSIQUE, NATURE, NOURRITURE, PHILOSOPHIE, PHYSIQUE, PLAGE, PORTUGAIS, PSYCHOLOGIE, RESEAUX_SOCIAUX, SERIES, SOLITAIRE,
  SORTIE, SPORTS, TATOUAGE, UNI_BASTION, UNI_DUFOUR, UNI_MAIL, UNI_SCIENCES, VOITURES, VOYAGE
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileServiceAPI apiService = ProfileServiceAPI();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  GenderEnum? _selectedGender;
  FaculteEnum? _selectedFaculty;
  ColorEnum? _selectedColor;
  List<GenderEnum> _selectedInterests = [];
  List<CenterOfInterestEnum> _selectedCentersOfInterest = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['fullname'] ?? '');
    _bioController = TextEditingController(text: widget.userData['description'] ?? '');

    _selectedGender = _getEnumValue<GenderEnum>(GenderEnum.values, widget.userData['gender']);
    _selectedFaculty = _getEnumValue<FaculteEnum>(FaculteEnum.values, widget.userData['faculte']);
    _selectedColor = _getEnumValue<ColorEnum>(ColorEnum.values, widget.userData['couleur']);

    _selectedInterests = (widget.userData['centersOfInterest'] as List?)
        ?.map((e) => _getEnumValue<GenderEnum>(GenderEnum.values, e))
        .whereType<GenderEnum>()
        .toList() ?? [];

    _selectedCentersOfInterest = (widget.userData['interests'] as List?)
        ?.map((e) => _getEnumValue<CenterOfInterestEnum>(CenterOfInterestEnum.values, e))
        .whereType<CenterOfInterestEnum>()
        .toList() ?? [];
  }

  T? _getEnumValue<T>(List<T> enumValues, String? value) {
    return enumValues.firstWhereOrNull((e) => e.toString().split('.').last == value);
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      widget.userData['fullname'] = _nameController.text;
      widget.userData['description'] = _bioController.text;
      widget.userData['gender'] = _selectedGender?.toString().split('.').last;
      widget.userData['faculte'] = _selectedFaculty?.toString().split('.').last;
      widget.userData['couleur'] = _selectedColor?.toString().split('.').last;
      widget.userData['interests'] = _selectedInterests.map((e) => e.toString().split('.').last).toList();
      widget.userData['centersOfInterest'] = _selectedCentersOfInterest.map((e) => e.toString().split('.').last).toList();

      final response = await apiService.updateUser(widget.userData);
      if (response.statusCode == 204) {
        Navigator.of(context).pop(true);
      } else {
        print('Failed to update profile: ${response.statusCode} - ${response.body}');
      }
    }
  }

  Future<void> _showMultiSelectDialog<T>(String title, List<T> items, List<T> selectedItems, void Function(List<T>) onItemsSelected) async {
  final List<T> tempSelectedItems = List.from(selectedItems);

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: items.map((item) {
                  return CheckboxListTile(
                    title: Text(item.toString().split('.').last),
                    value: tempSelectedItems.contains(item),
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked!) {
                          tempSelectedItems.add(item);
                        } else {
                          tempSelectedItems.remove(item);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  onItemsSelected(tempSelectedItems);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Lobster',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  icon: Icon(LineIcons.user, color: iconColor),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  icon: Icon(LineIcons.info, color: iconColor),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: Icon(LineIcons.graduationCap, color: iconColor),
                title: const Text(
                  'Faculty',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(LineIcons.angleDown, color: iconColor),
                onTap: () {
                  _showMultiSelectDialog<FaculteEnum>(
                    'Select Faculty',
                    FaculteEnum.values,
                    _selectedFaculty != null ? [_selectedFaculty!] : [],
                    (selectedItems) {
                      setState(() {
                        _selectedFaculty = selectedItems.isNotEmpty ? selectedItems.first : null;
                      });
                    },
                  );
                },
              ),
              if (_selectedFaculty != null) Chip(label: Text(_selectedFaculty!.toString().split('.').last)),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(LineIcons.palette, color: iconColor),
                title: const Text(
                  'Favorite Color',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(LineIcons.angleDown, color: iconColor),
                onTap: () {
                  _showMultiSelectDialog<ColorEnum>(
                    'Select Favorite Color',
                    ColorEnum.values,
                    _selectedColor != null ? [_selectedColor!] : [],
                    (selectedItems) {
                      setState(() {
                        _selectedColor = selectedItems.isNotEmpty ? selectedItems.first : null;
                      });
                    },
                  );
                },
              ),
              if (_selectedColor != null) Chip(label: Text(_selectedColor!.toString().split('.').last)),
              const SizedBox(height: 15),
              ListTile(
                leading: Icon(LineIcons.user, color: iconColor),
                title: const Text(
                  'Gender',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(LineIcons.angleDown, color: iconColor),
                onTap: () {
                  _showMultiSelectDialog<GenderEnum>(
                    'Select Gender',
                    GenderEnum.values,
                    _selectedGender != null ? [_selectedGender!] : [],
                    (selectedItems) {
                      setState(() {
                        _selectedGender = selectedItems.isNotEmpty ? selectedItems.first : null;
                      });
                    },
                  );
                },
              ),
              if (_selectedGender != null) Chip(label: Text(_selectedGender!.toString().split('.').last)),
              const SizedBox(height: 15),
              ListTile(
                leading: Icon(LineIcons.heart, color: iconColor),
                title: const Text(
                  'Interests',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(LineIcons.angleDown, color: iconColor),
                onTap: () {
                  _showMultiSelectDialog<GenderEnum>(
                    'Select Interests',
                    GenderEnum.values,
                    _selectedInterests,
                    (selectedItems) {
                      setState(() {
                        _selectedInterests = selectedItems;
                      });
                    },
                  );
                },
              ),
              Wrap(
                children: _selectedInterests.map((interest) => Chip(label: Text(interest.toString().split('.').last))).toList(),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: Icon(LineIcons.basketballBall, color: iconColor),
                title: const Text(
                  'Hobbies',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(LineIcons.angleDown, color: iconColor),
                onTap: () {
                  _showMultiSelectDialog<CenterOfInterestEnum>(
                    'Select Hobbies',
                    CenterOfInterestEnum.values,
                    _selectedCentersOfInterest,
                    (selectedItems) {
                      setState(() {
                        _selectedCentersOfInterest = selectedItems;
                      });
                    },
                  );
                },
              ),
              Wrap(
                children: _selectedCentersOfInterest.map((hobby) => Chip(label: Text(hobby.toString().split('.').last))).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Lobster',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension EnumExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (T element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
