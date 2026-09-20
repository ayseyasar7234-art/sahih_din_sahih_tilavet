@override
  _LessonFlowManagerState createState() => _LessonFlowManagerState();
}

class _LessonFlowManagerState extends State<LessonFlowManager> {
  late int currentLetterIndex;
  bool isPlayingGame = false;

  @override
  void initState() {
    super.initState();
    // Kaldığı harften devam etme özelliği
    currentLetterIndex = widget.appState.lastStudiedLetterIndex;
    if (currentLetterIndex >= AppData.alphabet.length) {
      currentLetterIndex = 0; // Başa sar
    }
  }

  void _onLearnCompleted() {
    setState(() {
      isPlayingGame = true; // Öğrenme bitti, oyun başlasın
    });
  }

  void _onGameCompleted(bool success) async {
    if (success) {
      await widget.appState.addScore(10); // Doğru eşleştirmeye 10 puan
      
      // Başarı animasyonu gösterimi
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const SuccessDialog(),
      );

      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context); // Dialogu kapat

      int nextIndex = currentLetterIndex + 1;
      
      if (nextIndex < AppData.alphabet.length) {
        // Sonraki harfe geç
        await widget.appState.saveLetterProgress(nextIndex);
        setState(() {
          currentLetterIndex = nextIndex;
          isPlayingGame = false;
        });
      } else {
        // Konu tamamen bitti!
        await widget.appState.addScore(50); // Konu bitirme puanı
        await widget.appState.unlockNextTopic(widget.topicIndex);
        await widget.appState.saveLetterProgress(0); // Bir sonraki konu için sıfırla
        
        if (mounted) {
          Navigator.pop(context); // Haritaya dön
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tebrikler! Konuyu tamamladın ve yeni konunun kilidini açtın! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // Yanlış cevap için müziksiz, sakin geri bildirim
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekrar deneyelim 🌸'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLetter = AppData.alphabet[currentLetterIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentLetterIndex + 1} / ${AppData.alphabet.length}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text('⭐ ${widget.appState.score}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: isPlayingGame
          ? MatchGameScreen(letter: currentLetter, onResult: _onGameCompleted)
          : LearnScreen(letter: currentLetter, onNext: _onLearnCompleted),
    );
  }
}

class LearnScreen extends StatelessWidget {
  final LetterItem letter;
  final VoidCallback onNext;

  const LearnScreen({Key? key, required this.letter, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sayfa açıldığında otomatik olarak eğitim yönergesi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioService.playInstruction("Şimdi harfi dinle.");
    });

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'HARFİ TANIYALIM',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Arapça Harf Kartı
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecorati
