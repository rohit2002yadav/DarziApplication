import sgMail from "@sendgrid/mail";

// API Key setup
if (process.env.SENDGRID_API_KEY) {
  sgMail.setApiKey(process.env.SENDGRID_API_KEY);
  console.log("✅ SENDGRID_API_KEY is loaded!"); // This line is now added
} else {
  console.error("❌ SENDGRID_API_KEY is missing in .env");
}

/**
 * Send OTP Email
 * @param {string} to
 * @param {string} otp
 */
export const sendOtpEmail = async (to, otp) => {
  try {
    const msg = {
      to,
      from: process.env.VERIFIED_EMAIL, 
      subject: "Your Darzi OTP Verification Code",
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #6a1b9a;">Darzi App Verification</h2>
          <p>Hello,</p>
          <p>Your one-time password (OTP) for account verification is:</p>
          <h1 style="color: #6a1b9a; letter-spacing: 5px; background: #f4f4f4; padding: 10px; display: inline-block;">${otp}</h1>
          <p>This code will expire in <b>10 minutes</b>.</p>
          <p>If you did not request this code, please ignore this email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin-top: 20px;" />
          <p style="font-size: 12px; color: #888;">Powered by Darzi Direct</p>
        </div>
      `,
    };

    await sgMail.send(msg);
    console.log("✅ OTP email successfully sent to:", to);
    return true;
  } catch (error) {
    console.error(
      "❌ SendGrid Mailer Error:",
      error.response?.body || error.message
    );
    return false;
  }
};
