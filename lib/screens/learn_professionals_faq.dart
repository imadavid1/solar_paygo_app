import 'package:solar_paygo_app/l10n/solar_language.dart';
import 'package:flutter/material.dart';

const learningQuestions = <(String, String)>[
  ('How do I request learning from a professional?',
    'Choose the skill you want to learn and contact SolarID with your location, current experience and preferred schedule. SolarID will discuss the enquiry and confirm whether a suitable professional and learning arrangement are available.'),
  ('Which skills can I explore?',
    'The platform includes 20 professional categories, including solar installation, electrical work, plumbing, painting, carpentry, welding, tiling and appliance repair. Ask which practical learning options are available in your area.'),
  ('Can a beginner enquire?',
    'Yes. Tell SolarID whether you are starting from the beginning or building on existing experience. The professional can discuss an appropriate starting point, the work involved and any preparation needed.'),
  ('What are the entry requirements?',
    'For the existing practical-learning enquiry, participants should be at least 18 and provide valid identification and contact details. Requirements may vary by trade. Confirm these, the schedule and any safety requirements with SolarID before making arrangements.'),
  ('Is learning available in my state?',
    'The directory supports all 36 Nigerian states and the FCT. Select your location or include it in your enquiry. Directory coverage does not guarantee that a trainer is currently available; SolarID will confirm local arrangements.'),
  ('How long does learning take and what does it cost?',
    'Duration and cost depend on the trade, your starting level and the agreed arrangement. Request the outline, schedule, fees and any tools or materials required before you commit. The website does not promise a fixed training price or duration.'),
  ('Will I receive a recognised certificate?',
    'Do not assume a certificate is included. Ask whether the learning provider offers one, who issues it and whether it is recognised for your intended work. SolarID should confirm the details before you enrol.'),
  ('How can I check a professional’s experience?',
    'Ask for relevant qualifications, examples of completed work and references. Discuss the tasks they can teach and how practical work is supervised. Names, photographs or years of experience in an illustrative profile are not proof of a verified qualification.'),
  ('What can I learn about solar and backup power?',
    'You can enquire about solar-system planning, panel installation, compatible batteries and inverters, maintenance and understanding energy use. Electrical and rooftop practical work should be supervised by an appropriately qualified professional.'),
  ('Is PAYGO payment the same as paying for training?',
    'No. SolarID’s PAYGO options concern purchasing power and receiving an activation token. Learning fees, where applicable, are a separate arrangement. Confirm the purpose, amount and recipient of any payment before proceeding.'),
  ('Can I also hire a worker for a project?',
    'Yes. Use Hire Skilled Workers to enquire about a job, or Find a Professional to explore a trade and location. Explain the scope of the work and ask SolarID to confirm availability, references, pricing and responsibilities.'),
  ('What should I send in my first enquiry?',
    'Include your preferred trade, state or city, experience level, learning goal and suitable days. The enquiry buttons open SolarID’s existing WhatsApp contact so you can discuss the next step directly.'),
];

/// One answer opens at a time; rows support pointer and keyboard activation.
class LearnProfessionalsFaq extends StatefulWidget {
  const LearnProfessionalsFaq({super.key});
  @override
  State<LearnProfessionalsFaq> createState() => _LearnProfessionalsFaqState();
}

class _LearnProfessionalsFaqState extends State<LearnProfessionalsFaq> {
  int? _open;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    width: double.infinity,
    color: const Color(0xFF162C3B),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 66),
    child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: LayoutBuilder(builder: (context, constraints) {
        const title = SolarText('Learning\nwith SolarID\nFAQs', style: TextStyle(
          color: Colors.white, fontSize: 36, height: 1.12,
          fontWeight: FontWeight.w700, letterSpacing: -.7));
        final questions = Column(children: [
          for (var i = 0; i < learningQuestions.length; i++)
            _QuestionRow(
              key: ValueKey('learning-question-$i'),
              question: learningQuestions[i].$1,
              answer: learningQuestions[i].$2,
              expanded: _open == i,
              onTap: () => setState(() => _open = _open == i ? null : i),
            ),
        ]);
        if (constraints.maxWidth < 760) return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [title, const SizedBox(height: 30), questions]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(width: 250, child: title),
          const SizedBox(width: 48), Expanded(child: questions),
        ]);
      }),
    )),
  ); }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({super.key, required this.question, required this.answer,
    required this.expanded, required this.onTap});
  final String question, answer;
  final bool expanded;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) { SolarLanguage.watch(context); return  Container(
    decoration: const BoxDecoration(border: Border(
      top: BorderSide(color: Color(0xFF527080), width: .7))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Material(color: Colors.transparent, child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFF25495E),
        focusColor: const Color(0xFF25495E),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 4),
          child: Row(children: [
            Expanded(child: SolarText(question, style: const TextStyle(
              color: Colors.white, fontSize: 15, height: 1.45, fontWeight: FontWeight.w600))),
            const SizedBox(width: 18),
            Semantics(label: expanded ? 'Collapse answer' : 'Expand answer',
              child: Container(width: 28, height: 28,
                decoration: const BoxDecoration(color: Color(0xFF78CBE5), shape: BoxShape.circle),
                child: Icon(expanded ? Icons.remove : Icons.add,
                  color: const Color(0xFF123749), size: 20))),
          ]),
        ),
      )),
      AnimatedSize(duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero : const Duration(milliseconds: 220),
        alignment: Alignment.topCenter,
        child: expanded
          ? Padding(padding: const EdgeInsets.fromLTRB(4, 0, 42, 22),
              child: SolarText(answer, style: const TextStyle(
                color: Color(0xFFDBE8EE), fontSize: 15, height: 1.65)))
          : const SizedBox(width: double.infinity),
      ),
    ]),
  ); }
}
