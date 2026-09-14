import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';

class CommunityPostDetailScreen extends StatefulWidget {
  final String postId;
  const CommunityPostDetailScreen({super.key, required this.postId});

  @override
  State<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends State<CommunityPostDetailScreen> {
  final _replyController = TextEditingController();
  bool _submittingReply = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _loadDetails() {
    Provider.of<DataProvider>(context, listen: false).fetchPostDetails(widget.postId);
  }

  void _handleSubmitReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _submittingReply = true;
    });

    final success = await Provider.of<DataProvider>(context, listen: false).addReply(
      widget.postId,
      text,
    );

    if (mounted) {
      setState(() {
        _submittingReply = false;
      });
      if (success) {
        _replyController.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit comment.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final post = dataProvider.selectedPost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Discussion'),
      ),
      body: dataProvider.isLoading && post == null
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
          : post == null
              ? const Center(child: Text('Failed to load post.'))
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async => _loadDetails(),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Main Post Card
                            Container(
                              decoration: AppTheme.cardDecoration(),
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.08), // Fixed .withValues error
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          post.category,
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        post.createdAt.length >= 10 
                                            ? post.createdAt.substring(0, 10) 
                                            : post.createdAt,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    post.title,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppTheme.primary,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    post.content,
                                    style: const TextStyle(height: 1.5, color: AppTheme.textDark, fontSize: 15),
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(color: AppTheme.borderLight),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.account_circle_outlined, size: 20, color: AppTheme.textMedium),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Posted by ${post.userName} (${post.userRole})',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Replies Section Header
                            Row(
                              children: [
                                Text(
                                  'Replies (${dataProvider.replies.length})',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(child: Divider(color: AppTheme.borderLight)),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Replies List
                            if (dataProvider.replies.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                  child: Text(
                                    'No replies yet. Be the first to start the conversation!',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textLight,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dataProvider.replies.length,
                                itemBuilder: (context, index) {
                                  final reply = dataProvider.replies[index];
                                  return _buildReplyItem(context, reply);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Reply Box Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(top: BorderSide(color: AppTheme.borderLight)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03), // Fixed .withValues error
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: authProvider.isAuthenticated
                                  ? TextField(
                                      controller: _replyController,
                                      decoration: const InputDecoration(
                                        hintText: 'Type your reply here...',
                                        filled: true,
                                        fillColor: Color(0xFFF1F5F9), // slate-100
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                      minLines: 1,
                                      maxLines: 3,
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      alignment: Alignment.center,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed('/login');
                                        },
                                        child: const Text(
                                          'Log in to reply to this thread',
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            if (authProvider.isAuthenticated) ...[
                              const SizedBox(width: 12),
                              _submittingReply
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.send, color: AppTheme.primary),
                                      onPressed: _handleSubmitReply,
                                    ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildReplyItem(BuildContext context, CommunityReply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Slate-50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reply.userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: reply.userRole == 'doctor' ? Colors.teal.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reply.userRole,
                  style: TextStyle(
                    color: reply.userRole == 'doctor' ? AppTheme.primary : AppTheme.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                reply.createdAt.length >= 10 ? reply.createdAt.substring(0, 10) : reply.createdAt,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.content,
            style: const TextStyle(fontSize: 14, color: AppTheme.textMedium, height: 1.4),
          ),
        ],
      ),
    );
  }
}