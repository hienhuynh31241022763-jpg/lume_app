import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../theme/app_colors.dart';
import '../home/demo_data.dart';
import '../home/home_product_card.dart';
import '../product_detail/product_route.dart';

class _NewsArticle {
  const _NewsArticle({
    required this.title,
    required this.topic,
    required this.excerpt,
    required this.date,
    required this.readTime,
    required this.image,
    required this.paragraphs,
    required this.relatedCategory,
  });

  final String title;
  final String topic;
  final String excerpt;
  final String date;
  final String readTime;
  final String image;
  final List<String> paragraphs;
  final String relatedCategory;
}

const _articles = [
  _NewsArticle(
    title: 'Chọn giày đi làm: thanh lịch mà vẫn thoải mái cả ngày',
    topic: 'Phong cách',
    excerpt:
        'Một đôi giày phù hợp giúp bạn tự tin từ cuộc họp đầu ngày đến lúc tan ca.',
    date: '01/11/2026',
    readTime: '4 phút đọc',
    image: 'assets/images/cat_cao_got.jpg',
    relatedCategory: 'Cao gót',
    paragraphs: [
      'Một ngày làm việc thường có nhiều cuộc hẹn và không ít thời gian di chuyển. Vì vậy, hãy bắt đầu từ cảm giác vừa vặn: mũi giày đủ rộng, gót chắc chắn và chất liệu mềm.',
      'Giày cao gót gót vuông hoặc giày búp bê là lựa chọn dễ phối cùng trang phục công sở. Các gam màu trung tính như đen, kem và nâu cũng giúp bạn sử dụng linh hoạt hơn.',
      'Nếu phải đi bộ nhiều, hãy ưu tiên đôi giày bạn đã mang thử vài lần. Sự thoải mái luôn là điểm nhấn đẹp nhất của một bộ trang phục.',
    ],
  ),
  _NewsArticle(
    title: 'Bí quyết chăm sóc giày để luôn như mới',
    topic: 'Chăm sóc',
    excerpt:
        'Vệ sinh đúng cách và cất giữ hợp lý giúp đôi giày bền đẹp qua nhiều mùa.',
    date: '28/10/2026',
    readTime: '3 phút đọc',
    image: 'assets/images/cat_sneaker.jpg',
    relatedCategory: 'Sneaker',
    paragraphs: [
      'Sau khi sử dụng, hãy dùng khăn mềm lau bụi và để giày khô tự nhiên ở nơi thoáng mát. Tránh đặt giày sát nguồn nhiệt hoặc phơi dưới nắng gắt.',
      'Với sneaker, có thể dùng bàn chải mềm để làm sạch phần đế và dây. Với chất liệu da hoặc da lộn, hãy chọn sản phẩm vệ sinh chuyên dụng và thử trước ở vùng khuất.',
      'Độn giấy sạch hoặc dùng shoe tree để giữ dáng. Nếu có thể, hãy luân phiên các đôi giày để mỗi đôi được nghỉ và khô hoàn toàn.',
    ],
  ),
  _NewsArticle(
    title: 'Sandal nào phù hợp cho những chuyến đi cuối tuần?',
    topic: 'Xu hướng',
    excerpt:
        'Gợi ý chọn sandal nhẹ, êm và dễ phối cho lịch trình dạo phố hay du lịch.',
    date: '25/10/2026',
    readTime: '3 phút đọc',
    image: 'assets/images/cat_sandal.jpg',
    relatedCategory: 'Sandal',
    paragraphs: [
      'Một chuyến đi thoải mái bắt đầu từ đôi sandal có quai giữ chân vừa vặn và đế đủ êm. Nếu lịch trình có nhiều đoạn đi bộ, hãy ưu tiên kiểu đế thấp hoặc đế xuồng vững.',
      'Sandal màu trung tính dễ phối với nhiều bộ đồ. Một đôi có quai điều chỉnh cũng hữu ích khi chân hơi nở sau một ngày vận động.',
      'Đừng quên mang thử giày trước chuyến đi và kiểm tra phần quai có cọ vào da không. Một chút chuẩn bị giúp bạn tận hưởng hành trình trọn vẹn hơn.',
    ],
  ),
  _NewsArticle(
    title: 'Tủ giày tối giản: 3 kiểu dáng dễ phối mỗi ngày',
    topic: 'Phong cách',
    excerpt:
        'Từ sneaker năng động đến giày búp bê nữ tính, chọn ít nhưng dùng được nhiều.',
    date: '20/10/2026',
    readTime: '5 phút đọc',
    image: 'assets/images/cat_giay_bup_be.jpg',
    relatedCategory: 'Giày búp bê',
    paragraphs: [
      'Một tủ giày gọn gàng không cần quá nhiều đôi. Hãy bắt đầu với một đôi sneaker cho ngày năng động, một đôi giày búp bê cho những dịp cần sự nhẹ nhàng và một kiểu giày phù hợp với môi trường làm việc.',
      'Chọn màu sắc có thể kết hợp với phần lớn quần áo bạn đang có. Kiểu dáng đơn giản thường dễ sử dụng lâu dài hơn những xu hướng chỉ xuất hiện trong thời gian ngắn.',
      'Trước khi mua thêm, hãy nghĩ đến ít nhất ba trang phục bạn có thể phối cùng đôi giày đó.',
    ],
  ),
];

const _topics = ['Tất cả', 'Xu hướng', 'Phong cách', 'Chăm sóc'];

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String _topic = _topics.first;

  void _openArticle(_NewsArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _NewsArticleScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleArticles = _topic == 'Tất cả'
        ? _articles
        : _articles.where((article) => article.topic == _topic).toList();
    final featured = _articles.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Tin tức & xu hướng')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: _FeaturedArticle(
              article: featured,
              onTap: () => _openArticle(featured),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _topics.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final topic = _topics[index];
                return ChoiceChip(
                  label: Text(topic),
                  selected: _topic == topic,
                  onSelected: (_) => setState(() => _topic = topic),
                  selectedColor: AppColors.blush,
                  labelStyle: TextStyle(
                    color: _topic == topic
                        ? AppColors.roseDark
                        : AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: _topic == topic ? AppColors.rose : AppColors.line,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              _topic == 'Tất cả' ? 'Bài viết mới nhất' : _topic,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          for (final article in visibleArticles)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _ArticleTile(
                article: article,
                onTap: () => _openArticle(article),
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  const _FeaturedArticle({required this.article, required this.onTap});

  final _NewsArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              width: double.infinity,
              child: _ArticleImage(path: article.image),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _NewsBadge(label: 'BÀI NỔI BẬT'),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.excerpt,
                    style: const TextStyle(
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ArticleMeta(article: article),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article, required this.onTap});

  final _NewsArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 124,
          child: Row(
            children: [
              SizedBox(width: 116, height: double.infinity, child: _ArticleImage(path: article.image)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        article.topic.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.roseDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${article.date} · ${article.readTime}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.chevron_right, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleImage extends StatelessWidget {
  const _ArticleImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.blush,
        child: Icon(Icons.auto_awesome, color: AppColors.rose, size: 42),
      ),
    );
  }
}

class _NewsBadge extends StatelessWidget {
  const _NewsBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.roseDark,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _ArticleMeta extends StatelessWidget {
  const _ArticleMeta({required this.article});

  final _NewsArticle article;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          article.topic,
          style: const TextStyle(
            color: AppColors.roseDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text('  ·  ', style: TextStyle(color: AppColors.muted)),
        Text(
          '${article.date}  ·  ${article.readTime}',
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _NewsArticleScreen extends StatelessWidget {
  const _NewsArticleScreen({required this.article});

  final _NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = productsOf(provider)
        .where((product) => product.category == article.relatedCategory)
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bài viết')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          SizedBox(height: 230, child: _ArticleImage(path: article.image)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NewsBadge(label: article.topic.toUpperCase()),
                const SizedBox(height: 12),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                _ArticleMeta(article: article),
                const SizedBox(height: 22),
                for (final paragraph in article.paragraphs) ...[
                  Text(
                    paragraph,
                    style: const TextStyle(
                      color: AppColors.ink,
                      height: 1.7,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                Text(
                  'Gợi ý dành cho bạn',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (products.isEmpty)
                  const Text(
                    'Sản phẩm liên quan sẽ được cập nhật.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else
                  SizedBox(
                    height: HomeProductCard.heightFor(164),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return SizedBox(
                          width: 164,
                          child: HomeProductCard(
                            product: product,
                            heroTag:
                                'news-${article.topic}-${product.id}-$index',
                            onTap: () => openProductDetail(
                              context,
                              product,
                              heroTag:
                                  'news-${article.topic}-${product.id}-$index',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
