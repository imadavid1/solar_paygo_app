import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'imad_about_section.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../marketplace/marketplace_data.dart';
import '../marketplace/professional_directory.dart';
import 'professional_video_hero.dart';
import 'professional_loop_strip.dart';
import '../marketplace/marketplace_theme.dart';
import '../marketplace/marketplace_widgets.dart';

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key, required this.onCustomerAccess});
  final VoidCallback onCustomerAccess;
  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  String _profession = allProfessions;
  String _location = allLocations;
  String _query = '';
  String get _displayProfession => _profession == allProfessions ? 'Solar Installer' : _profession;
  String get _displayLocation => _location == allLocations ? 'FCT Abuja' : _location;

  void _search() {
    final result = searchSampleProfessionals(profession: _profession, location: _location, query: _query);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _ProfessionalResultsScreen(
      onCustomerAccess: widget.onCustomerAccess, result: result,
    )));
  }

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Find a professional', 
        onCustomerAccess: widget.onCustomerAccess,
        hero: const ProfessionalVideoHero(),
        title: 'Find a trusted professional',
        subtitle: 'Choose a trade and Nigerian location, or type directly into the search box. Compare qualified profiles and contact the professional who fits your job.',
        child: Column(children: [
          PageSection(
            color: MarketColors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle(title: 'Search by service and location', subtitle: 'Twenty professional categories are available across all 36 states and the FCT.', icon: Icons.manage_search_rounded),
              const SizedBox(height: 27),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: MarketColors.mist, borderRadius: BorderRadius.circular(18), border: Border.all(color: MarketColors.line)),
                child: LayoutBuilder(builder: (context, constraints) {
                  final fields = [
                    DropdownButtonFormField<String>(initialValue: _profession, isExpanded: true, decoration: const SolarInputDecoration(labelText: 'Profession', prefixIcon: Icon(Icons.engineering_outlined)), items: [allProfessions, ...professionTypes].map((value) => DropdownMenuItem(value: value, child: SolarText(value))).toList(), onChanged: (value) => setState(() { _profession = value ?? _profession; })),
                    DropdownButtonFormField<String>(initialValue: _location, isExpanded: true, decoration: const SolarInputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on_outlined)), items: [allLocations, ...nigeriaLocations].map((value) => DropdownMenuItem(value: value, child: SolarText(value))).toList(), onChanged: (value) => setState(() { _location = value ?? _location; })),
                    TextField(onChanged: (value) => setState(() => _query = value), onSubmitted: (_) => _search(), decoration: const SolarInputDecoration(labelText: 'Type a name or service', prefixIcon: Icon(Icons.search_rounded))),
                  ];
                  if (constraints.maxWidth >= 900) return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: fields[0]), const SizedBox(width: 14), Expanded(child: fields[1]), const SizedBox(width: 14), Expanded(child: fields[2]), const SizedBox(width: 14), HoverButton(label: 'Search', icon: Icons.search_rounded, onPressed: _search)]);
                  return Column(children: [fields[0], const SizedBox(height: 14), fields[1], const SizedBox(height: 14), fields[2], const SizedBox(height: 14), HoverButton(label: 'Search professionals', icon: Icons.search_rounded, onPressed: _search, expanded: true)]);
                }),
              ),
            ]),
          ),
          PageSection(
            color: MarketColors.white,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SectionTitle(title: 'Recommended $_displayProfession professionals', subtitle: 'Illustrative profiles; names, experience and photos are examples. All enquiries connect to SolarID.'),
              const SizedBox(height: 30),
              ProfessionalLoopStrip(
                key: ValueKey('$_displayProfession/$_displayLocation'),
                profiles: sampleProfessionalsFor(_displayProfession, _displayLocation),
                panelBuilder: (context, profile, pauseForAction) => _ProfessionalWidePanel(
                  profile: profile,
                  onOpen: () => pauseForAction(() => _showProfessionalDetails(context, profile)),
                ),
              ),
            ]),
          ),
          const ImadAboutSection(),
        ]),
      ); }
}

/// Preserves existing training and careers content until their redesign.
class WorkforceServicesScreen extends StatelessWidget {
  const WorkforceServicesScreen({super.key, required this.onCustomerAccess, required this.initialSelection});
  final VoidCallback onCustomerAccess;
  final int initialSelection;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Find a professional', 
    onCustomerAccess: onCustomerAccess,
    title: initialSelection == 2 ? 'Careers' : 'Learn from Professionals',
    subtitle: 'Explore practical skills, guidance and opportunities with SolarID.',
    child: _WorkforceOpportunities(initialSelection: initialSelection),
  ); }
}

class _WorkforceOpportunities extends StatefulWidget {
  const _WorkforceOpportunities({this.initialSelection = 0});
  final int initialSelection;

  @override
  State<_WorkforceOpportunities> createState() => _WorkforceOpportunitiesState();
}

class _WorkforceOpportunitiesState extends State<_WorkforceOpportunities> {
  late int selected = widget.initialSelection;

  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    return PageSection(
      color: MarketColors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionTitle(
          title: 'Build skills. Find opportunities.',
          subtitle: 'Connect with available skilled workers or arrange practical training with experienced professionals.',
          icon: Icons.handyman_outlined,
        ),
        const SizedBox(height: 30),
        Wrap(spacing: 34, runSpacing: 10, children: [
          _OpportunityTab(label: 'Hire Skilled Workers', active: selected == 0, onTap: () => setState(() => selected = 0)),
          _OpportunityTab(label: 'Learn from Professionals', active: selected == 1, onTap: () => setState(() => selected = 1)),
          _OpportunityTab(label: 'Careers', active: selected == 2, onTap: () => setState(() => selected = 2)),
        ]),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: selected == 0
              ? const _OpportunityPanel(
                  key: ValueKey('hire'),
                  title: 'Hire reliable skilled workers',
                  introduction: 'Choose trained people for daily, weekly or project-based support. SolarID coordinates the introduction and confirms availability.',
                  points: ['Select the required profession and location', 'Review skills and years of experience', 'Agree the job period and responsibilities', 'Confirm availability through SolarID', 'Use verified contact details before work begins'],
                  button: 'Request a skilled worker',
                  message: 'Hello SolarID, I need help finding a skilled worker.',
                  imageAsset: 'assets/images/hire_skilled_worker.png',
                  imageLabel: 'Skilled solar technician installing a rooftop solar system',
                )
              : selected == 1
              ? const _OpportunityPanel(
                  key: ValueKey('learn'),
                  title: 'Learn directly from professionals',
                  introduction: 'Apply for practical guidance, short training or supervised experience with a professional in your chosen trade.',
                  points: ['Be at least 18 years old', 'Provide valid identification and contact details', 'Choose the skill and preferred location', 'State your current experience level', 'Agree the training schedule and safety requirements'],
                  button: 'Enquire about training',
                  message: 'Hello SolarID, I would like to learn from a professional.',
                  imageAsset: 'assets/images/learn_from_professional.png',
                  imageLabel: 'Technical trainee learning solar installation from a professional',
                )
              : const _CareersPanel(key: ValueKey('careers')),
        ),
      ]),
    );
  }
}

class _CareersPanel extends StatefulWidget {
  const _CareersPanel({super.key});

  @override
  State<_CareersPanel> createState() => _CareersPanelState();
}

class _CareersPanelState extends State<_CareersPanel> {
  static const _slides = [
    ('assets/images/hire_skilled_worker.png', 'Solar Installation Assistant'),
    ('assets/images/career_electrical_technician.png', 'Electrical Technician'),
    ('assets/images/career_field_support.png', 'Field Support Officer'),
    ('assets/images/learn_from_professional.png', 'Apprentice Solar Installer'),
  ];
  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _current = (_current + 1) % _slides.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final image = ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 850),
                    child: SizedBox(
                      key: ValueKey(_slides[_current].$1),
                      height: 510,
                      width: double.infinity,
                      child: Image.asset(_slides[_current].$1, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      decoration: BoxDecoration(color: MarketColors.ink.withValues(alpha: .86), borderRadius: BorderRadius.circular(14)),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: SolarText(_slides[_current].$2, key: ValueKey(_slides[_current].$2), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ),
            );
            final copy = Padding(
  padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 30),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SolarText(
        'CAREERS AT SolarID',
        style: TextStyle(
          color: MarketColors.greenDark,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
        ),
      ),
      const SizedBox(height: 16),
      const SolarText(
        'Build your career with SolarID',
        style: TextStyle(
          color: MarketColors.ink,
          fontSize: 38,
          height: 1.08,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 18),
      const SolarText(
        'Join a growing network delivering dependable solar energy and skilled technical services. Explore full-time, contract and supervised training opportunities across installation, electrical work, field support and apprenticeships.',
        style: TextStyle(
          color: MarketColors.muted,
          fontSize: 17,
          height: 1.6,
        ),
      ),
      const SizedBox(height: 24),
      const Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _CareerPill('Solar installation'),
          _CareerPill('Electrical services'),
          _CareerPill('Field support'),
          _CareerPill('Apprenticeships'),
        ],
      ),
      const SizedBox(height: 30),
      HoverButton(
        label: 'Apply now',
        icon: Icons.arrow_forward_rounded,
        onPressed: _apply,
      ),
    ],
  ),
);
            return constraints.maxWidth >= 900
                ? SizedBox(height: 510, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(flex: 11, child: image), const SizedBox(width: 26), Expanded(flex: 9, child: copy)]))
                : Column(children: [image, const SizedBox(height: 24), copy]);
          }),
          const SizedBox(height: 34),
          const SolarText('The application process', style: TextStyle(color: MarketColors.ink, fontSize: 29, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          const _ApplicationStep(title: '1. Choose an opportunity', body: 'Review the role, location, responsibilities and experience requirements before applying.'),
          const _ApplicationStep(title: '2. Submit your information', body: 'Provide your name, contact details, location, experience and a short description of your suitability.'),
          const _ApplicationStep(title: '3. Verification and screening', body: 'SolarID reviews the information and may request identification, qualifications or references.'),
          const _ApplicationStep(title: '4. Interview or practical assessment', body: 'Shortlisted applicants may complete an interview or demonstrate relevant practical skills.'),
          const _ApplicationStep(title: '5. Placement and onboarding', body: 'Successful applicants receive the engagement details, safety expectations and agreed start date.'),
        ],
      ); }

  static void _apply() => openImadWhatsApp('Hello SolarID, I would like to apply for a career opportunity.');
}

class _CareerPill extends StatelessWidget {
  const _CareerPill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .78), borderRadius: BorderRadius.circular(999), border: Border.all(color: MarketColors.line)),
        child: SolarText(label, style: const TextStyle(color: MarketColors.ink, fontWeight: FontWeight.w800)),
      ); }
}

class _ApplicationStep extends StatelessWidget {
  const _ApplicationStep({required this.title, required this.body});
  final String title, body;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: MarketColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: MarketColors.line)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: MarketColors.greenDark,
          collapsedIconColor: MarketColors.ink,
          title: SolarText(title, style: const TextStyle(color: MarketColors.ink, fontWeight: FontWeight.w900)),
          children: [Align(alignment: Alignment.centerLeft, child: SolarText(body, style: const TextStyle(color: MarketColors.muted, height: 1.5)))],
        ),
      ); }
}

class _OpportunityTab extends StatelessWidget {
  const _OpportunityTab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: active ? MarketColors.skyStrong : Colors.transparent, width: 4))),
          child: SolarText(label, style: TextStyle(color: MarketColors.ink, fontWeight: FontWeight.w900, fontSize: 20)),
        ),
      ); }
}

class _OpportunityPanel extends StatelessWidget {
  const _OpportunityPanel({super.key, required this.title, required this.introduction, required this.points, required this.button, required this.message, required this.imageAsset, required this.imageLabel});
  final String title, introduction, button, message, imageAsset, imageLabel;
  final List<String> points;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(color: MarketColors.mist, borderRadius: BorderRadius.circular(20), border: Border.all(color: MarketColors.line)),
        child: LayoutBuilder(builder: (context, constraints) {
          final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SolarText(title, style: const TextStyle(color: MarketColors.ink, fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            SolarText(introduction, style: const TextStyle(color: MarketColors.muted, fontSize: 16, height: 1.55)),
            const SizedBox(height: 22),
            ...points.map((point) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle_outline_rounded, color: MarketColors.green, size: 21), const SizedBox(width: 10), Expanded(child: SolarText(point, style: const TextStyle(color: MarketColors.ink, fontWeight: FontWeight.w600)))]))),
            const SizedBox(height: 14),
            HoverButton(label: button, icon: Icons.chat_rounded, onPressed: () => openImadWhatsApp(message)),
          ]);
          final art = Semantics(
            image: true,
            label: imageLabel,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 330,
                width: double.infinity,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),
          );
          return constraints.maxWidth >= 850 ? Row(children: [Expanded(child: art), const SizedBox(width: 44), Expanded(child: copy)]) : Column(children: [art, const SizedBox(height: 28), copy]);
        }),
      ); }
}

class _ProfessionalWidePanel extends StatelessWidget {
  const _ProfessionalWidePanel({required this.profile, required this.onOpen});
  final SampleProfessional profile;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  LayoutBuilder(builder: (context, constraints) {
    final compact = constraints.maxWidth < 580;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(fit: StackFit.expand, children: [
        _ProfessionalPhoto(profile: profile),
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          stops: [.05, .38, .72, 1],
          colors: [Color(0x00132F42), Color(0x18132F42), Color(0xD5102C3E), Color(0xFA102C3E)],
        ))),
        Positioned(left: compact ? 18 : 30, right: compact ? 18 : 30, bottom: compact ? 22 : 30,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            SolarText(profile.name, translate: false, style: TextStyle(color: Colors.white, fontSize: compact ? 25 : 34, height: 1.1, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            SolarText(profile.profession, style: TextStyle(color: const Color(0xFFBEEFFF), fontSize: compact ? 16 : 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Wrap(spacing: 18, runSpacing: 8, children: [
              _ProfessionalMetadata(icon: Icons.location_on_outlined, label: profile.location),
              _ProfessionalMetadata(icon: Icons.work_history_outlined, label: '${profile.yearsExperience} years of experience'),
            ]),
            const SizedBox(height: 20),
            SizedBox(width: 190, child: HoverButton(label: 'View & contact', icon: Icons.chat_rounded, expanded: true, onPressed: onOpen)),
          ]),
        ),
      ]),
    );
  }); }
}

class _ProfessionalMetadata extends StatelessWidget {
  const _ProfessionalMetadata({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 18, color: const Color(0xFFBEEFFF)),
    const SizedBox(width: 7),
    Flexible(child: SolarText(label, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35))),
  ]); }
}

class _ProfessionalCard extends StatefulWidget {
  const _ProfessionalCard({required this.profile});
  final SampleProfessional profile;
  @override
  State<_ProfessionalCard> createState() => _ProfessionalCardState();
}

class _ProfessionalCardState extends State<_ProfessionalCard> {
  bool hovered = false;
  SampleProfessional get _profile => widget.profile;
  @override
  Widget build(BuildContext context) {
    SolarLanguage.watch(context);
    final profile = _profile;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        scale: hovered ? 1.018 : 1,
        duration: const Duration(milliseconds: 180),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, hovered ? -7 : 0, 0),
          decoration: BoxDecoration(color: MarketColors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: hovered ? MarketColors.skyStrong : MarketColors.line), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: hovered ? .15 : .06), blurRadius: hovered ? 24 : 10, offset: Offset(0, hovered ? 11 : 4))]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AspectRatio(aspectRatio: 1.15, child: Container(color: MarketColors.sky, child: _ProfessionalPhoto(profile: profile))),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SolarText(profile.name, translate: false, style: const TextStyle(color: MarketColors.ink, fontWeight: FontWeight.w900, fontSize: 19)),
                  const SizedBox(height: 7),
                  SolarText(profile.profession, style: const TextStyle(color: MarketColors.greenDark, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(children: [const Icon(Icons.location_on_outlined, size: 17, color: MarketColors.muted), const SizedBox(width: 4), Expanded(child: SolarText(profile.location, style: const TextStyle(color: MarketColors.muted)))]),
                  const SizedBox(height: 8),
                  SolarText('${profile.yearsExperience} years of experience', style: const TextStyle(color: MarketColors.muted, fontSize: 13)),
                  const SizedBox(height: 15),
                  HoverButton(label: 'View & contact', icon: Icons.chat_rounded, expanded: true, onPressed: _details),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _details() => _showProfessionalDetails(context, _profile);
}

Future<void> _showProfessionalDetails(BuildContext context, SampleProfessional profile) async {
  await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: SolarText(profile.name, translate: false),
      content: SizedBox(width: 440, child: SingleChildScrollView(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          AspectRatio(aspectRatio: 1.5, child: _ProfessionalPhoto(profile: profile)),
          const SizedBox(height: 20),
          SolarText('${profile.profession} · ${profile.location}', style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          SolarText('${profile.yearsExperience} years of experience'),
          const SizedBox(height: 12),
          const SolarText('Email', style: TextStyle(fontWeight: FontWeight.w700)),
          SelectableText(profile.email),
          const SizedBox(height: 12),
          SolarText('SolarID WhatsApp: +$imadWhatsAppNumber'),
          const SizedBox(height: 16),
          const SolarText('Illustrative profile. Contact SolarID to arrange an available professional.',
            style: TextStyle(color: MarketColors.muted, height: 1.5)),
        ],
      ))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const SolarText('Close')),
        HoverButton(label: 'Contact SolarID', icon: Icons.chat_outlined,
          onPressed: () => openImadWhatsApp('Hello SolarID, I am looking for a ${profile.profession} in ${profile.location}. I viewed sample profile ${profile.name} (${profile.id}). Please connect me with an available professional.')),
      ],
    ));
}

class _ProfessionalPhoto extends StatelessWidget {
  const _ProfessionalPhoto({required this.profile});
  final SampleProfessional profile;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Semantics(
    image: true,
    label: 'Illustrative ${profile.isFemale ? 'female' : 'male'} ${profile.profession} at work',
    child: ClipRect(child: FittedBox(fit: BoxFit.cover, alignment: Alignment.topCenter, child: ClipRect(child: Align(
      alignment: Alignment(profile.photoIndex.isOdd ? 1 : -1, (profile.photoIndex ~/ 2).toDouble() - 1),
      widthFactor: .5, heightFactor: 1 / 3,
      child: Image.asset(profile.imageAsset, width: 1200, height: 1200, cacheWidth: 1200, fit: BoxFit.fill, errorBuilder: (context, error, stack) => const SizedBox(width: 1200, height: 1200, child: ColoredBox(color: Color(0xFFDDF4FA), child: Center(child: Icon(Icons.person_outline_rounded, size: 160, color: Color(0xFF17638C)))))),
    )))),
  ); }
}

class _ProfessionalResultsScreen extends StatelessWidget {
  const _ProfessionalResultsScreen({required this.onCustomerAccess, required this.result});
  final VoidCallback onCustomerAccess;
  final ProfessionalSearchResult result;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  MarketplaceShell(activeSection: 'Find a professional', 
    onCustomerAccess: onCustomerAccess,
    title: result.title,
    subtitle: result.notice.startsWith('No exact name or service match')
        ? 'No exact match.'
        : '${result.total} illustrative profiles match these filters. Names, experience and photos are examples; all enquiries connect to SolarID.',
    child: PageSection(color: MarketColors.white, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_rounded), label: const SolarText('Back to search')),
      if (result.notice.isNotEmpty) ...[
        const SizedBox(height: 16),
        SolarText(result.notice, style: const TextStyle(color: MarketColors.muted, height: 1.5)),
      ],
      const SizedBox(height: 24),
      SolarText('Showing ${result.profiles.length} of ${result.total} profiles', style: const TextStyle(color: MarketColors.muted)),
      const SizedBox(height: 24),
      LayoutBuilder(builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1080 ? 4 : constraints.maxWidth >= 730 ? 3 : constraints.maxWidth >= 480 ? 2 : 1;
        final width = (constraints.maxWidth - (columns - 1) * 20) / columns;
        return Wrap(spacing: 20, runSpacing: 20, children: [
          for (final p in result.profiles) SizedBox(width: width, child: _ProfessionalCard(profile: p)),
        ]);
      }),
    ])),
  ); }
}

