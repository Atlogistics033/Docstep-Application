import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { ArrowLeft, MessageSquare, Send } from 'lucide-react';

export default function CommunityPost() {
  const { id } = useParams();
  const { user, showFlash } = useAuth();

  const [post, setPost] = useState(null);
  const [replies, setReplies] = useState([]);
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  const fetchPostDetails = () => {
    setLoading(true);
    axios.get(`/api/public/community/${id}`)
      .then((res) => {
        if (res.data.success) {
          setPost(res.data.post);
          setReplies(res.data.replies || []);
        }
      })
      .catch((err) => console.error('Failed to load post details', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchPostDetails();
  }, [id]);

  const handleReplySubmit = async (e) => {
    e.preventDefault();
    if (!content.trim()) {
      showFlash('error', 'Reply content cannot be empty.');
      return;
    }
    setSubmitting(true);
    try {
      const res = await axios.post(`/api/public/community/${id}/reply`, { content });
      if (res.data.success) {
        showFlash('success', 'Reply posted successfully!');
        setContent('');
        // Re-fetch post details to get the new list of replies
        fetchPostDetails();
      } else {
        showFlash('error', res.data.error || 'Failed to post reply.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to post reply.');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading post details...
      </div>
    );
  }

  if (!post) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-20 text-center">
        <h2 className="font-display font-bold text-2xl text-navy-800">Post not found</h2>
        <Link to="/community" className="btn btn-outline mt-6 inline-flex">
          Back to community
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-12 text-left fade-in">
      <Link to="/community" className="text-sm text-slate-500 hover:text-teal-700 flex items-center gap-1">
        <ArrowLeft className="w-4 h-4" /> Back to community
      </Link>

      {/* Main Post Card */}
      <div className="card card-pad mt-4 bg-white">
        <div className="flex items-center justify-between mb-3">
          <span className="badge badge-lavender">{post.category}</span>
          <span className="text-xs text-slate-500">{new Date(post.created_at).toDateString()}</span>
        </div>
        <h1 className="font-display font-extrabold text-2xl md:text-3xl text-navy-800">
          {post.title}
        </h1>
        <div className="text-sm text-slate-500 mt-1">
          By <span className="font-semibold text-navy-800">{post.full_name}</span>
        </div>
        <p className="text-slate-700 leading-relaxed mt-5 whitespace-pre-line">{post.content}</p>
      </div>

      {/* Replies Container */}
      <div className="mt-8">
        <h2 className="font-display font-bold text-xl text-navy-800 mb-4 flex items-center gap-1.5">
          <MessageSquare className="w-5 h-5 text-slate-500" /> {replies.length} Replies
        </h2>
        <div className="space-y-3">
          {replies.map((r) => (
            <div key={r.id} className="card card-pad bg-white">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 rounded-full bg-gradient-to-br from-teal-400 to-lavender-300 text-white flex items-center justify-center font-bold text-xs">
                  {r.full_name
                    .split(' ')
                    .map((p) => p[0])
                    .slice(0, 2)
                    .join('')}
                </div>
                <div className="font-semibold text-sm text-navy-800">{r.full_name}</div>
                <div className="text-xs text-slate-500 ml-auto">
                  {new Date(r.created_at).toDateString()}
                </div>
              </div>
              <p className="text-sm text-slate-700 whitespace-pre-line">{r.content}</p>
            </div>
          ))}
          {replies.length === 0 && (
            <div className="text-sm text-slate-500 text-center py-4">
              No replies yet. Be the first to respond.
            </div>
          )}
        </div>

        {/* Add Reply Box */}
        <div className="card card-pad mt-6 bg-white">
          <h3 className="font-semibold text-navy-800 mb-3">Add a reply</h3>
          {!user ? (
            <p className="text-sm text-slate-600">
              Please{' '}
              <Link to="/login" className="text-teal-700 font-semibold hover:underline">
                login
              </Link>{' '}
              to reply.
            </p>
          ) : (
            <form onSubmit={handleReplySubmit} className="space-y-3">
              <div>
                <textarea
                  name="content"
                  required
                  rows="3"
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  className="textarea"
                  placeholder="Share your thoughts..."
                ></textarea>
              </div>
              <button type="submit" disabled={submitting} className="btn btn-primary inline-flex text-sm">
                <Send className="w-4 h-4 mr-1.5" />
                {submitting ? 'Posting...' : 'Post reply'}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
