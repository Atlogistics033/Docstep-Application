const dbService = require('../db/dbService');

(async () => {
  try {
    const employerId = 'Fbfdvfiu2CSxr96NOfD6WqqTH0k2'; // Saifee Hospital user_id
    const appointments = await dbService.getAppointmentsByEmployer(employerId);
    console.log(`Appointments found: ${appointments.length}`);
    appointments.forEach(a => {
      console.log(`- ID: ${a.id}, Patient: ${a.patient_name}, Status: ${a.status}, Employer ID: ${a.employer_id}`);
    });
    
    const activeAppointments = appointments.filter(a => {
      const s = (a.status || 'scheduled').toLowerCase();
      return s !== 'cancelled' && s !== 'cancel' && s !== 'canceled';
    });
    console.log(`Active Count: ${activeAppointments.length}`);
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
