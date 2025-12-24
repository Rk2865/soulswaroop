class EnneagramQuestion {
  final String text;
  final int type; // 1-9

  const EnneagramQuestion({
    required this.text,
    required this.type,
  });
}

class EnneagramType {
  final String title;
  final String long;

  const EnneagramType({
    required this.title,
    required this.long,
  });
}

const List<EnneagramQuestion> enneagramQuestions = [
  EnneagramQuestion(text: "I strongly fear being seen as inadequate or not good enough.", type: 3),
  EnneagramQuestion(text: "I often worry that people will leave me or lose interest in me.", type: 2),
  EnneagramQuestion(text: "I avoid conflict because harmony and peace feel more important than winning.", type: 9),
  EnneagramQuestion(text: "I feel a strong need to be capable, self-reliant, and prepared for anything.", type: 6),
  EnneagramQuestion(text: "I constantly seek to be appreciated or valued for being helpful to others.", type: 2),
  EnneagramQuestion(text: "I want to be unique or special in some way, and I dislike feeling ordinary.", type: 4),
  EnneagramQuestion(text: "I prefer being in control and taking charge rather than being told what to do.", type: 8),
  EnneagramQuestion(text: "I want to improve myself and everything around me — flaws irritate me.", type: 1),
  EnneagramQuestion(text: "I need to feel successful or admired to feel secure about who I am.", type: 3),
  EnneagramQuestion(text: "Experiences, fun, and excitement drive me more than rules or routine.", type: 7),
  EnneagramQuestion(text: "I experience emotions intensely, and I often analyze them deeply.", type: 4),
  EnneagramQuestion(text: "I hide my vulnerability and show strength, even when I’m hurting inside.", type: 8),
  EnneagramQuestion(text: "I feel restless or anxious if my life becomes predictable or boring.", type: 7),
  EnneagramQuestion(text: "When stressed, I withdraw and go inside my mind to solve things alone.", type: 5),
  EnneagramQuestion(text: "I avoid uncomfortable feelings by staying busy or distracted.", type: 7),
  EnneagramQuestion(text: "I act as a peacemaker and avoid asserting myself even when I should.", type: 9),
  EnneagramQuestion(text: "Helping others gives me emotional satisfaction and makes me feel wanted.", type: 2),
  EnneagramQuestion(text: "I push myself to achieve and be recognized because I fear being “nobody.”", type: 3),
  EnneagramQuestion(text: "I rely heavily on logic and analysis rather than emotions when deciding.", type: 5),
  EnneagramQuestion(text: "I question things easily and rarely trust something at face value.", type: 6),
];

// Placeholder descriptions - User to update with exact HTML content if needed
const Map<int, EnneagramType> enneagramTypes = {
  1: EnneagramType(title: "The Reformer (Perfectionist)", long: "Principled, disciplined, and motivated to improve things. You set high standards and can be hard on yourself or others when they are not met. Growth involves practicing self‑compassion and allowing room for imperfection as part of learning."),
  2: EnneagramType(title: "The Helper (Giver)", long: "Warm, generous, and focused on others’ needs. You feel valuable when you are helpful and appreciated, but may overlook your own needs. Growth means setting healthy boundaries and asking directly for care and support."),
  3: EnneagramType(title: "The Achiever (Performer)", long: "Ambitious, efficient, and driven by goals. You want to succeed and be seen as competent, and may downplay vulnerability to maintain a strong image. Growth involves slowing down, being authentic, and valuing yourself beyond achievements."),
  4: EnneagramType(title: "The Individualist (Romantic)", long: "Emotionally deep, sensitive, and authenticity‑seeking. You often feel different and long for a unique identity. Growth means balancing emotional intensity with gratitude, practical routines, and perspective outside your inner story."),
  5: EnneagramType(title: "The Investigator (Observer)", long: "Analytical, private, and knowledge‑oriented. You conserve energy, prefer independence, and seek understanding before acting. Growth involves sharing more of yourself, staying present in your body, and engaging consistently with others."),
  6: EnneagramType(title: "The Loyalist (Skeptic)", long: "Reliable, cautious, and security‑focused. You scan for risks and value trustworthy people and systems. Growth comes from building inner confidence, tolerating uncertainty, and taking action even when you do not feel completely sure."),
  7: EnneagramType(title: "The Enthusiast (Adventurer)", long: "Optimistic, energetic, and drawn to new experiences. You like options and avoid feeling trapped in pain or boredom. Growth involves practicing focus, finishing what you start, and allowing uncomfortable feelings instead of escaping them."),
  8: EnneagramType(title: "The Challenger (Protector)", long: "Strong‑willed, direct, and protective of yourself and others. You value control and fairness and may hide vulnerability. Growth involves softening your stance, listening fully, and letting trusted people see your more tender side."),
  9: EnneagramType(title: "The Peacemaker (Mediator)", long: "Calm, supportive, and harmony‑seeking. You dislike conflict and may minimize your own priorities to keep peace. Growth means clarifying what you want, taking small decisive steps, and speaking up more consistently."),
};
