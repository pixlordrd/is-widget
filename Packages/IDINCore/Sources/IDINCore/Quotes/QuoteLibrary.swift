import Foundation

/// Thirty lines on acting, starting and finishing — all from public-domain thinkers,
/// and only renderings that trace back to a real source. Popular misattributions
/// (e.g. "we are what we repeatedly do", which is Will Durant summarising Aristotle)
/// are deliberately left out.
public enum QuoteLibrary {
    public static let all: [Quote] = [
        Quote(
            id: 1,
            english: "Waste no more time arguing what a good man should be. Be one.",
            turkish: "İyi bir insanın nasıl olacağını tartışarak vakit kaybetme. Öyle biri ol.",
            authorEnglish: "Marcus Aurelius",
            authorTurkish: "Marcus Aurelius"
        ),
        Quote(
            id: 2,
            english: "Do every act of your life as though it were the last act of your life.",
            turkish: "Hayatındaki her işi, son işinmiş gibi yap.",
            authorEnglish: "Marcus Aurelius",
            authorTurkish: "Marcus Aurelius"
        ),
        Quote(
            id: 3,
            english: "Confine yourself to the present.",
            turkish: "Kendini şimdiye ver.",
            authorEnglish: "Marcus Aurelius",
            authorTurkish: "Marcus Aurelius"
        ),
        Quote(
            id: 4,
            english: "While we are postponing, life speeds by.",
            turkish: "Biz erteledikçe hayat hızla geçip gidiyor.",
            authorEnglish: "Seneca",
            authorTurkish: "Seneca"
        ),
        Quote(
            id: 5,
            english: "It is not that we have a short time to live, but that we waste much of it.",
            turkish: "Yaşamak için kısa bir zamanımız yok; onun çoğunu harcıyoruz.",
            authorEnglish: "Seneca",
            authorTurkish: "Seneca"
        ),
        Quote(
            id: 6,
            english: "First say to yourself what you would be; then do what you have to do.",
            turkish: "Önce kendine ne olmak istediğini söyle; sonra gerekeni yap.",
            authorEnglish: "Epictetus",
            authorTurkish: "Epiktetos"
        ),
        Quote(
            id: 7,
            english: "No great thing is created suddenly.",
            turkish: "Hiçbir büyük şey bir anda oluşmaz.",
            authorEnglish: "Epictetus",
            authorTurkish: "Epiktetos"
        ),
        Quote(
            id: 8,
            english: "The things we have to learn before we can do them, we learn by doing them.",
            turkish: "Yapmadan önce öğrenmemiz gereken şeyleri, yaparak öğreniriz.",
            authorEnglish: "Aristotle",
            authorTurkish: "Aristoteles"
        ),
        Quote(
            id: 9,
            english: "The beginning is the most important part of the work.",
            turkish: "İşin en önemli kısmı başlangıcıdır.",
            authorEnglish: "Plato",
            authorTurkish: "Platon"
        ),
        Quote(
            id: 10,
            english: "The first and best victory is to conquer self.",
            turkish: "İlk ve en iyi zafer, insanın kendini yenmesidir.",
            authorEnglish: "Plato",
            authorTurkish: "Platon"
        ),
        Quote(
            id: 11,
            english: "Nothing endures but change.",
            turkish: "Değişimden başka hiçbir şey kalıcı değildir.",
            authorEnglish: "Heraclitus",
            authorTurkish: "Herakleitos"
        ),
        Quote(
            id: 12,
            english: "Do not put off your work until tomorrow and the day after.",
            turkish: "İşini yarına, öbür güne bırakma.",
            authorEnglish: "Hesiod",
            authorTurkish: "Hesiodos"
        ),
        Quote(
            id: 13,
            english: "While we stop to think, we often miss our opportunity.",
            turkish: "Düşünmek için durduğumuzda fırsatı çoğu zaman kaçırırız.",
            authorEnglish: "Publilius Syrus",
            authorTurkish: "Publilius Syrus"
        ),
        Quote(
            id: 14,
            english: "Dripping water hollows out stone.",
            turkish: "Damlayan su taşı oyar.",
            authorEnglish: "Ovid",
            authorTurkish: "Ovidius"
        ),
        Quote(
            id: 15,
            english: "They can because they think they can.",
            turkish: "Yapabilirler, çünkü yapabileceklerine inanırlar.",
            authorEnglish: "Virgil",
            authorTurkish: "Vergilius"
        ),
        Quote(
            id: 16,
            english: "The beginnings of all things are small.",
            turkish: "Her şeyin başlangıcı küçüktür.",
            authorEnglish: "Cicero",
            authorTurkish: "Cicero"
        ),
        Quote(
            id: 17,
            english: "A journey of a thousand miles begins with a single step.",
            turkish: "Bin kilometrelik yolculuk tek bir adımla başlar.",
            authorEnglish: "Lao Tzu",
            authorTurkish: "Lao Tzu"
        ),
        Quote(
            id: 18,
            english: "Great acts are made up of small deeds.",
            turkish: "Büyük işler küçük işlerden oluşur.",
            authorEnglish: "Lao Tzu",
            authorTurkish: "Lao Tzu"
        ),
        Quote(
            id: 19,
            english: "The virtuous man is sparing in words but generous in deeds.",
            turkish: "Erdemli insan sözde ölçülü, işte cömerttir.",
            authorEnglish: "Confucius",
            authorTurkish: "Konfüçyüs"
        ),
        Quote(
            id: 20,
            english: "In the midst of chaos, there is also opportunity.",
            turkish: "Kargaşanın ortasında fırsat da vardır.",
            authorEnglish: "Sun Tzu",
            authorTurkish: "Sun Tzu"
        ),
        Quote(
            id: 21,
            english: "Do nothing which is of no use.",
            turkish: "Faydası olmayan hiçbir şeyi yapma.",
            authorEnglish: "Miyamoto Musashi",
            authorTurkish: "Miyamoto Musashi"
        ),
        Quote(
            id: 22,
            english: "Well done is better than well said.",
            turkish: "İyi yapılmış, iyi söylenmişten iyidir.",
            authorEnglish: "Benjamin Franklin",
            authorTurkish: "Benjamin Franklin"
        ),
        Quote(
            id: 23,
            english: "Lost time is never found again.",
            turkish: "Kaybedilen zaman bir daha bulunmaz.",
            authorEnglish: "Benjamin Franklin",
            authorTurkish: "Benjamin Franklin"
        ),
        Quote(
            id: 24,
            english: "Knowing is not enough; we must apply. Willing is not enough; we must do.",
            turkish: "Bilmek yetmez, uygulamak gerek. İstemek yetmez, yapmak gerek.",
            authorEnglish: "Johann Wolfgang von Goethe",
            authorTurkish: "Johann Wolfgang von Goethe"
        ),
        Quote(
            id: 25,
            english: "Do the thing and you shall have the power.",
            turkish: "İşi yap, güç sana gelir.",
            authorEnglish: "Ralph Waldo Emerson",
            authorTurkish: "Ralph Waldo Emerson"
        ),
        Quote(
            id: 26,
            english: "Nothing great was ever achieved without enthusiasm.",
            turkish: "Hiçbir büyük şey coşku olmadan başarılmadı.",
            authorEnglish: "Ralph Waldo Emerson",
            authorTurkish: "Ralph Waldo Emerson"
        ),
        Quote(
            id: 27,
            english: "It is not enough to be busy; so are the ants. The question is what we are busy about.",
            turkish: "Meşgul olmak yetmez; karıncalar da meşgul. Soru şu: neyle meşgulüz?",
            authorEnglish: "Henry David Thoreau",
            authorTurkish: "Henry David Thoreau"
        ),
        Quote(
            id: 28,
            english: "Genius is one percent inspiration and ninety-nine percent perspiration.",
            turkish: "Dehanın yüzde biri ilham, yüzde doksan dokuzu terdir.",
            authorEnglish: "Thomas Edison",
            authorTurkish: "Thomas Edison"
        ),
        Quote(
            id: 29,
            english: "Life is not easy for any of us. But what of that? We must have perseverance.",
            turkish: "Hiçbirimiz için hayat kolay değil. Ne fark eder? Azimli olmalıyız.",
            authorEnglish: "Marie Curie",
            authorTurkish: "Marie Curie"
        ),
        Quote(
            id: 30,
            english: "The two most powerful warriors are patience and time.",
            turkish: "En güçlü iki savaşçı sabır ve zamandır.",
            authorEnglish: "Leo Tolstoy",
            authorTurkish: "Lev Tolstoy"
        )
    ]

    /// A random quote, never repeating the one already on screen.
    public static func random(excluding previous: Quote? = nil) -> Quote {
        guard let previous else {
            return all.randomElement() ?? all[0]
        }
        return all.filter { $0.id != previous.id }.randomElement() ?? previous
    }
}
