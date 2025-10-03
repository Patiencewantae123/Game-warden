// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(GameWardenApp());
}

class GameWardenApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Warden',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // Sample local state (patrols & incidents). In a real app, this would come from a DB / API.
  final List<Map<String, String>> patrols = [
    {
      'title': 'Morning Patrol - Sector A',
      'date': '2025-10-01',
      'notes': 'Routine check, no incidents.'
    },
    {
      'title': 'River Patrol - Sector B',
      'date': '2025-09-28',
      'notes': 'Found abandoned camp, reported.'
    }
  ];

  final List<Map<String, String>> incidents = [
    {
      'title': 'Suspicious Vehicle',
      'date': '2025-09-30',
      'description': 'Vehicle seen near waterhole after dusk.'
    }
  ];

  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Dashboard(
          onQuickReport: _openIncidentForm,
          patrols: patrols,
          incidents: incidents,
        );
      case 1:
        return PatrolsPage(
          patrols: patrols,
          onAddPatrol: (newPatrol) {
            setState(() {
              patrols.insert(0, newPatrol);
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Patrol added successfully')));
          },
        );
      case 2:
        return IncidentsPage(
          incidents: incidents,
          onAddIncident: (newIncident) {
            setState(() {
              incidents.insert(0, newIncident);
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Incident reported successfully')));
          },
        );
      case 3:
        return ResourcesPage();
      case 4:
        return ProfilePage();
      default:
        return Center(child: Text('Unknown'));
    }
  }

  void _openIncidentForm() async {
    _fabController.forward().then((_) => _fabController.reverse());
    final result = await showDialog<Map<String, String>>(
        context: context, builder: (_) => IncidentFormDialog());
    if (result != null) {
      setState(() {
        incidents.insert(0, result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incident reported: ${result['title']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Dashboard', 'Patrols', 'Incidents', 'Resources', 'Profile'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: AppDrawer(),
      body: _buildBody(),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut))
            .animate(_fabController),
        child: FloatingActionButton.extended(
          onPressed: _openIncidentForm,
          label: Text('Report Incident'),
          icon: Icon(Icons.report_problem),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dash'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Patrols'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Incidents'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Resources'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final VoidCallback onQuickReport;
  final List<Map<String, String>> patrols;
  final List<Map<String, String>> incidents;

  Dashboard(
      {required this.onQuickReport,
      required this.patrols,
      required this.incidents});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    int totalPatrols = patrols.length;
    int totalIncidents = incidents.length;
    int activeAlerts = totalIncidents; // simple example

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Greeting card
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[200],
                child: Icon(Icons.eco, color: Colors.green[900]),
              ),
              title: Text('Good day, Warden'),
              subtitle: Text('Stay safe. Monitor the wildlife reserve.'),
              trailing: ElevatedButton(
                onPressed: onQuickReport,
                child: Text('Quick Report'),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              Expanded(
                child: StatCard(
                    title: 'Patrols',
                    value: totalPatrols.toString(),
                    icon: Icons.shield),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatCard(
                    title: 'Incidents',
                    value: totalIncidents.toString(),
                    icon: Icons.report),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatCard(
                    title: 'Alerts',
                    value: activeAlerts.toString(),
                    icon: Icons.warning),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Recent patrols
          SectionHeader(title: 'Recent Patrols'),
          ...patrols.take(3).map((p) => ListTile(
                leading: Icon(Icons.directions_walk),
                title: Text(p['title'] ?? ''),
                subtitle: Text(p['date'] ?? ''),
                trailing: TextButton(child: Text('View'), onPressed: () {}),
              )),

          SizedBox(height: 12),

          // Recent incidents
          SectionHeader(title: 'Recent Incidents'),
          ...incidents.take(3).map((i) => ListTile(
                leading: Icon(Icons.report_gmailerrorred),
                title: Text(i['title'] ?? ''),
                subtitle: Text(i['date'] ?? ''),
                trailing: TextButton(child: Text('Details'), onPressed: () {}),
              )),

          SizedBox(height: 20),

          // Quick tips / resources
          SectionHeader(title: 'Quick Tips'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  '• Always record exact GPS coordinates when possible.\n• Wear protective gear on night patrols.\n• Report suspicious activity immediately.'),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.green[700]),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Spacer(),
        ],
      ),
    );
  }
}

class PatrolsPage extends StatefulWidget {
  final List<Map<String, String>> patrols;
  final void Function(Map<String, String>) onAddPatrol;

  PatrolsPage({required this.patrols, required this.onAddPatrol});

  @override
  _PatrolsPageState createState() => _PatrolsPageState();
}

class _PatrolsPageState extends State<PatrolsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  void _openAddPatrol() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Wrap(
                  children: [
                    Text('Add Patrol',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Patrol Title'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(labelText: 'Notes'),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              _titleController.clear();
                              _notesController.clear();
                              Navigator.pop(context);
                            },
                            child: Text('Cancel')),
                        ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                final newPatrol = {
                                  'title': _titleController.text.trim(),
                                  'date': DateTime.now()
                                      .toIso8601String()
                                      .split('T')
                                      .first,
                                  'notes': _notesController.text.trim()
                                };
                                widget.onAddPatrol(newPatrol);
                                _titleController.clear();
                                _notesController.clear();
                                Navigator.pop(context);
                              }
                            },
                            child: Text('Add'))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: widget.patrols.isEmpty
                ? Center(child: Text('No patrols yet. Add one.'))
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: widget.patrols.length,
                    itemBuilder: (_, i) {
                      final p = widget.patrols[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.directions_walk),
                          title: Text(p['title'] ?? ''),
                          subtitle: Text(p['notes'] ?? ''),
                          trailing: Text(p['date'] ?? ''),
                        ),
                      );
                    })),
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _openAddPatrol,
            icon: Icon(Icons.add),
            label: Text('Add Patrol'),
          ),
        )
      ],
    );
  }
}

class IncidentsPage extends StatelessWidget {
  final List<Map<String, String>> incidents;
  final void Function(Map<String, String>) onAddIncident;

  IncidentsPage({required this.incidents, required this.onAddIncident});

  void _openForm(BuildContext context) async {
    final result = await showDialog<Map<String, String>>(
        context: context, builder: (_) => IncidentFormDialog());
    if (result != null) {
      onAddIncident(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: incidents.isEmpty
                ? Center(child: Text('No incidents reported yet.'))
                : ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: incidents.length,
                    itemBuilder: (_, i) {
                      final it = incidents[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.report_gmailerrorred),
                          title: Text(it['title'] ?? ''),
                          subtitle: Text(it['description'] ?? ''),
                          trailing: Text(it['date'] ?? ''),
                        ),
                      );
                    })),
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon: Icon(Icons.report),
            label: Text('Report Incident'),
          ),
        )
      ],
    );
  }
}

class IncidentFormDialog extends StatefulWidget {
  @override
  _IncidentFormDialogState createState() => _IncidentFormDialogState();
}

class _IncidentFormDialogState extends State<IncidentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report Incident'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: 'Incident Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 8),
              // In a real app you'd add GPS, photo upload, severity, etc.
              Text('Tip: include GPS coordinates and photos if available.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newIncident = {
                  'title': _title.text.trim(),
                  'description': _description.text.trim(),
                  'date': DateTime.now().toIso8601String().split('T').first
                };
                Navigator.pop(context, newIncident);
              }
            },
            child: Text('Submit')),
      ],
    );
  }
}

class ResourcesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This could link to maps, SOP docs, wildlife ID guides, emergency contacts, etc.
    return ListView(
      padding: EdgeInsets.all(12),
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.map),
            title: Text('Maps & Zones'),
            subtitle: Text('Open the reserve map and boundaries.'),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.book),
            title: Text('Standard Operating Procedures'),
            subtitle: Text('Patrol rules, safety & incident escalation.'),
            onTap: () {},
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.phone),
            title: Text('Emergency Contacts'),
            subtitle: Text('Rangers, Vet Hospital, Police, Park HQ'),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple profile placeholder
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: Colors.green[100],
            child: Icon(Icons.person, size: 46, color: Colors.green[800]),
          ),
          SizedBox(height: 12),
          Text('Warden Patience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Game Warden • Zone A', style: TextStyle(color: Colors.grey[700])),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.email),
              title: Text('patience@example.com'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.phone),
              title: Text('+254 7XX XXX XXX'),
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Game Warden',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              )),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.feedback),
            title: Text('Send Feedback'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
