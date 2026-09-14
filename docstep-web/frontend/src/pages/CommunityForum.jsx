import React, { useState, useEffect, useRef } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { MessageSquare, Send, BookOpen, HeartHandshake, Sparkles, RotateCcw } from 'lucide-react';

export default function CommunityForum() {
  const { user, showFlash } = useAuth();
  const navigate = useNavigate();

  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  // New post form state
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('Returning to Practice');
  const [content, setContent] = useState('');
  const [submitting, setSubmitting] = useState(false);

  // AI Chatbot state
  const [chatInput, setChatInput] = useState('');
  const [chatMessages, setChatMessages] = useState([
    {
      id: 1,
      sender: 'bot',
      text: 'Hello! I am DocStep Medical AI. I can assist you with questions related to diseases, doctors, and other medical topics. How can I help you today?'
    }
  ]);
  const [chatLoading, setChatLoading] = useState(false);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [chatMessages, chatLoading]);

  const fetchPosts = () => {
    setLoading(true);
    axios.get('/api/public/community')
      .then((res) => {
        if (res.data.success) {
          setPosts(res.data.posts);
        }
      })
      .catch((err) => console.error('Failed to load posts', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchPosts();
  }, []);

  const handlePostSubmit = async (e) => {
    e.preventDefault();
    if (!title || !content) {
      showFlash('error', 'Title and content are required.');
      return;
    }
    setSubmitting(true);
    try {
      const res = await axios.post('/api/public/community/new', { title, category, content });
      if (res.data.success) {
        showFlash('success', 'Thread posted successfully!');
        setTitle('');
        setContent('');
        // Navigate to the post details page
        navigate(`/community/${res.data.postId}`);
      } else {
        showFlash('error', res.data.error || 'Failed to post thread.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to post thread.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleClearChat = () => {
    setChatMessages([
      {
        id: 1,
        sender: 'bot',
        text: 'Hello! I am DocStep Medical AI. I can assist you with questions related to diseases, doctors, and other medical topics. How can I help you today?'
      }
    ]);
    setChatInput('');
    setChatLoading(false);
  };

  const handleSendChatMessage = async (e) => {
    e.preventDefault();
    if (!chatInput.trim() || chatLoading) return;

    const userMsgText = chatInput.trim();
    const userMessage = {
      id: Date.now(),
      sender: 'user',
      text: userMsgText
    };

    setChatMessages((prev) => [...prev, userMessage]);
    setChatInput('');
    setChatLoading(true);

    try {
      const systemPrompt = `You are DocStep Medical AI, a specialized medical AI assistant.
You can ONLY answer questions related to the medical field, diseases, symptoms, doctors, medicines, healthcare, biology, anatomy, and health sciences.
If the user asks ANY question or says anything outside of the medical domain (for example: general knowledge, coding, history, politics, sports, math, jokes, pop culture, non-medical advice, recipes, translating non-medical text, or writing general essays), you must NOT answer it. Instead, respond politely, explaining that you are programmed to only assist with medical-related queries.
Keep your medical answers clear, professional, and concise.`;

      // Filter out the initial greeting (index 0) from the conversation history sent to the Gemini API
      // as Gemini requires the conversation to start with a 'user' role.
      const conversationHistory = chatMessages.slice(1).map((msg) => ({
        role: msg.sender === 'user' ? 'user' : 'model',
        parts: [{ text: msg.text }]
      }));

      // Add the new user message to the history
      conversationHistory.push({
        role: 'user',
        parts: [{ text: userMsgText }]
      });

      // Inject system prompt into the first user message
      if (conversationHistory.length > 0 && conversationHistory[0].role === 'user') {
        conversationHistory[0].parts[0].text = `${systemPrompt}\n\nUser Question: ${conversationHistory[0].parts[0].text}`;
      }

      const apiKey = 'Enter your Gemini API key here';

      const res = await axios.post(url, {
        contents: conversationHistory
      });

      const responseText = res.data.candidates?.[0]?.content?.parts?.[0]?.text || 'I did not receive a response from the AI.';

      setChatMessages((prev) => [
        ...prev,
        {
          id: Date.now() + 1,
          sender: 'bot',
          text: responseText
        }
      ]);
    } catch (err) {
      console.error('Gemini Chatbot Error:', err);
      setChatMessages((prev) => [
        ...prev,
        {
          id: Date.now() + 1,
          sender: 'bot',
          text: 'Sorry, I encountered an error. Please try again.'
        }
      ]);
    } finally {
      setChatLoading(false);
    }
  };

  return (
    <div className="fade-in text-left">
      {/* Hero Header */}
      <section className="hero-gradient">
        <div className="max-w-6xl mx-auto px-4 pt-14 pb-10">
          <div className="brand-pill mb-3">Community</div>
          <h1 className="font-display font-extrabold text-3xl md:text-5xl text-navy-800">
            Conversations that support your return
          </h1>
          <p className="text-slate-600 mt-3 max-w-2xl">
            A safe peer space for women doctors — share questions, advice, and stories.
          </p>
        </div>
      </section>

      {/* Forum Content */}
      <section className="max-w-6xl mx-auto px-4 py-12 grid lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 space-y-4">
          {loading ? (
            <div className="text-center py-10 text-slate-500">Loading conversations...</div>
          ) : posts.length === 0 ? (
            <div className="card card-pad text-center text-slate-500">
              No posts yet. Be the first to start a thread.
            </div>
          ) : (
            posts.map((p) => (
              <Link key={p.id} to={`/community/${p.id}`} className="card card-pad block hover:no-underline">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <h3 className="font-display font-bold text-lg text-navy-800 hover:text-teal-600">
                      {p.title}
                    </h3>
                    <div className="text-xs text-slate-500 mt-1">
                      By <span className="font-semibold text-navy-800">{p.full_name}</span> •{' '}
                      {new Date(p.created_at).toDateString()}
                    </div>
                  </div>
                  <span className="badge badge-lavender shrink-0">{p.category}</span>
                </div>
                <p className="text-sm text-slate-600 mt-3 line-clamp-2">{p.content}</p>
                <div className="flex items-center gap-4 mt-4 text-xs text-slate-500">
                  <span className="flex items-center gap-1">
                    <MessageSquare className="w-3.5 h-3.5 text-slate-400" /> {p.reply_count} replies
                  </span>
                </div>
              </Link>
            ))
          )}
        </div>

        {/* Sidebar */}
        <aside className="space-y-4">
          <div className="card card-pad bg-white">
            <h3 className="font-display font-bold text-lg text-navy-800 mb-2">
              Start a new thread
            </h3>
            {!user ? (
              <div>
                <p className="text-sm text-slate-600 mb-3">Login or create an account to post.</p>
                <Link to="/login" className="btn btn-primary w-full justify-center text-sm">
                  Login
                </Link>
              </div>
            ) : (
              <form onSubmit={handlePostSubmit} className="space-y-3">
                <div>
                  <input
                    name="title"
                    required
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="input"
                    placeholder="Title of your post"
                  />
                </div>
                <div>
                  <select
                    name="category"
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="select"
                  >
                    <option>Returning to Practice</option>
                    <option>Telemedicine</option>
                    <option>Mental Health</option>
                    <option>Returnship</option>
                    <option>Licensing</option>
                    <option>General</option>
                  </select>
                </div>
                <div>
                  <textarea
                    name="content"
                    required
                    rows="4"
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                    className="textarea"
                    placeholder="Share your question or story..."
                  ></textarea>
                </div>
                <button type="submit" disabled={submitting} className="btn btn-primary w-full justify-center text-sm">
                  <Send className="w-4 h-4 mr-1.5" />
                  {submitting ? 'Posting...' : 'Post'}
                </button>
              </form>
            )}
          </div>

          {/* AI Chatbot Card */}
          <div className="card card-pad bg-white shadow-sm border border-slate-100 rounded-2xl flex flex-col">
            <div className="flex items-center justify-between border-b border-slate-100 pb-3 mb-3">
              <div className="flex items-center gap-2">
                <Sparkles className="w-5 h-5 text-teal-600 animate-pulse" />
                <h3 className="font-display font-bold text-navy-800 text-lg">DocStep Medical AI</h3>
              </div>
              <button
                type="button"
                onClick={handleClearChat}
                className="text-slate-400 hover:text-slate-600 transition-colors"
                title="Reset conversation"
              >
                <RotateCcw className="w-4 h-4" />
              </button>
            </div>

            {/* Messages Display */}
            <div className="flex flex-col gap-3 h-64 overflow-y-auto pr-1 mb-3 scrollbar-thin">
              {chatMessages.map((msg) => (
                <div
                  key={msg.id}
                  className={`flex flex-col ${
                    msg.sender === 'user' ? 'items-end' : 'items-start'
                  }`}
                >
                  <div
                    className={`rounded-2xl px-3.5 py-2 text-sm max-w-[85%] leading-relaxed ${
                      msg.sender === 'user'
                        ? 'bg-teal-600 text-white rounded-tr-none'
                        : 'bg-slate-100 text-slate-700 rounded-tl-none'
                    }`}
                  >
                    {msg.text}
                  </div>
                  <span className="text-[10px] text-slate-400 mt-1 px-1">
                    {msg.sender === 'user' ? 'You' : 'DocStep AI'}
                  </span>
                </div>
              ))}
              {chatLoading && (
                <div className="flex items-start">
                  <div className="bg-slate-100 text-slate-500 rounded-2xl rounded-tl-none px-3.5 py-2 text-sm max-w-[85%] flex gap-1 items-center">
                    <span className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce duration-300 delay-75"></span>
                    <span className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce duration-300 delay-150"></span>
                    <span className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce duration-300 delay-225"></span>
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </div>

            {/* Input Form */}
            <form onSubmit={handleSendChatMessage} className="flex gap-2">
              <input
                type="text"
                className="input flex-1 px-3 py-1.5 text-sm border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                placeholder="Ask any medical question..."
                value={chatInput}
                onChange={(e) => setChatInput(e.target.value)}
                disabled={chatLoading}
              />
              <button
                type="submit"
                disabled={chatLoading || !chatInput.trim()}
                className="bg-teal-600 hover:bg-teal-700 text-white font-semibold p-2 rounded-xl transition-colors disabled:bg-slate-200 disabled:text-slate-400 shrink-0"
              >
                <Send className="w-4 h-4" />
              </button>
            </form>
          </div>

          <div className="card card-pad bg-gradient-to-br from-lavender-50 to-teal-50">
            <h3 className="font-display font-bold text-navy-800 mb-2 flex items-center gap-1.5">
              <HeartHandshake className="w-5 h-5 text-lavender-700" /> Guidelines
            </h3>
            <ul className="text-sm text-slate-700 space-y-1">
              <li>• Be kind and respectful.</li>
              <li>• Keep patient information confidential.</li>
              <li>• No promotional or spam content.</li>
              <li>• Women-only space — moderated for safety.</li>
            </ul>
          </div>
        </aside>
      </section>
    </div>
  );
}
