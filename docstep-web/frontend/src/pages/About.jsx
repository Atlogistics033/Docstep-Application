import React from 'react';

export default function About() {
  const team = [
    { name: 'Syed Hasan Abdullah', roll: '2022F-BIT-044', role: 'Backend Developer + Database', color: 'from-teal-400 to-teal-600' },
    { name: 'Syed Haider Raza Naqvi', roll: '2022F-BIT-053', role: 'Research + Testing + Documentation', color: 'from-lavender-300 to-lavender-500' },
    { name: 'M. Arham Akhtar', roll: '2022F-BIT-014', role: 'Frontend Developer + UI/UX', color: 'from-navy-700 to-navy-800' }
  ];

  const comparisonRows = [
    ['Focus group', 'General public', 'General public', 'General public', 'Women doctors & patients'],
    ['Doctor pool', 'Mixed gender', 'Mixed gender', 'Mixed gender', 'Exclusively women doctors'],
    ['Privacy for patients', 'Medium', 'Medium', 'Medium', 'High — women-only interface'],
    ['Career-return support', 'None', 'None', 'None', 'Returnship + mentorship + courses'],
    ['Psychotherapy support', 'Limited', 'Limited', 'Limited', 'Strong focus'],
    ['Community outreach', 'None', 'Minimal', 'Moderate', 'NGOs / CSR partnerships'],
  ];

  return (
    <div className="fade-in">
      {/* Hero Header */}
      <section className="hero-gradient">
        <div className="max-w-5xl mx-auto px-4 pt-16 pb-20 text-center">
          <div className="brand-pill mb-4">About DocStep</div>
          <h1 className="font-display font-extrabold text-4xl md:text-5xl text-navy-800 leading-tight">
            Bridging the gap between paused careers and the patients who need them.
          </h1>
          <p className="text-lg text-slate-600 mt-6 max-w-3xl mx-auto leading-relaxed">
            In Pakistan, a significant loss of valuable medical expertise occurs as many female doctors discontinue their practice after marriage or motherhood. At the same time, women and children — especially in under-served communities — face barriers to accessing care. DocStep was built to close that gap.
          </p>
        </div>
      </section>

      {/* Mission / Vision */}
      <section className="max-w-7xl mx-auto px-4 py-20">
        <div className="grid lg:grid-cols-2 gap-10">
          <div className="card card-pad text-left">
            <div className="badge badge-teal mb-3">Our Mission</div>
            <h2 className="font-display font-bold text-2xl text-navy-800 mb-3">
              Empower women doctors to return — sustainably
            </h2>
            <p className="text-slate-600 leading-relaxed">
              Provide flexible employment, training, mentorship, and telemedicine opportunities so that no medical career is lost to caregiving, marriage, or relocation.
            </p>
          </div>
          <div className="card card-pad text-left">
            <div className="badge badge-lavender mb-3">Our Vision</div>
            <h2 className="font-display font-bold text-2xl text-navy-800 mb-3">
              A healthcare system that values every doctor's path
            </h2>
            <p className="text-slate-600 leading-relaxed">
              A Pakistan where every woman doctor can continue practising on her own terms — and every woman patient can access verified, private, compassionate care.
            </p>
          </div>
        </div>
      </section>

      {/* SDG Alignment */}
      <section className="section-soft py-20 text-left">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center mb-12">
            <div className="brand-pill mb-3">Aligned with Global Goals</div>
            <h2 className="font-display font-bold text-3xl text-navy-800">
              UN Sustainable Development Goals
            </h2>
          </div>
          <div className="grid md:grid-cols-2 gap-6 max-w-4xl mx-auto">
            <div className="card card-pad flex gap-5 items-start">
              <div className="w-16 h-16 rounded-xl bg-green-600 flex items-center justify-center text-white font-display font-extrabold text-2xl shrink-0">
                3
              </div>
              <div>
                <div className="font-display font-bold text-xl text-navy-800">Good Health & Well-being</div>
                <p className="text-sm text-slate-600 mt-2">
                  Improves access to healthcare for women and children — especially in remote and conservative communities — through verified telemedicine and returning women doctors.
                </p>
              </div>
            </div>
            <div className="card card-pad flex gap-5 items-start">
              <div className="w-16 h-16 rounded-xl bg-amber-600 flex items-center justify-center text-white font-display font-extrabold text-2xl shrink-0">
                5
              </div>
              <div>
                <div className="font-display font-bold text-xl text-navy-800">Gender Equality</div>
                <p className="text-sm text-slate-600 mt-2">
                  Empowers women medical professionals to continue contributing their expertise while balancing family responsibilities and career growth.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>



      {/* Comparisons */}
      <section className="section-soft py-20">
        <div className="max-w-6xl mx-auto px-4">
          <div className="text-center mb-10">
            <div className="brand-pill mb-3">Why DocStep</div>
            <h2 className="font-display font-bold text-3xl text-navy-800">How we compare</h2>
          </div>
          <div className="card overflow-hidden overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-navy-800 text-white">
                <tr>
                  <th className="text-left p-4">Feature</th>
                  <th className="p-4">Sehat Kahani</th>
                  <th className="p-4">Oladoc</th>
                  <th className="p-4">Marham</th>
                  <th className="p-4 bg-teal-600">DocStep</th>
                </tr>
              </thead>
              <tbody className="text-slate-700">
                {comparisonRows.map((r, i) => (
                  <tr key={i} className={`border-t border-slate-100 ${i % 2 === 0 ? 'bg-slate-50/40' : ''}`}>
                    <td className="p-4 font-semibold text-navy-800 text-left">{r[0]}</td>
                    <td className="p-4 text-center">{r[1]}</td>
                    <td className="p-4 text-center">{r[2]}</td>
                    <td className="p-4 text-center">{r[3]}</td>
                    <td className="p-4 text-center bg-teal-50 font-semibold text-teal-800">{r[4]}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>
    </div>
  );
}
