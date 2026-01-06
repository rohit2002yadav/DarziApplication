import sgMail from "@sendgrid/mail";

// Set SendGrid API key from .env
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

/**
 * Send OTP Email
 * @param {string} to - receiver email
 * @param {string} otp - OTP code
 */
export const sendOtpEmail = async (to, otp) => {
  try {
    const msg = {
      to,
      from: process.env.VERIFIED_EMAIL, // must be verified in SendGrid
      subject: "Your Darzi OTP Verification Code",
      html: `
        <div style="font-family: Arial, sans-serif;">
          <h2>Darzi App</h2>
          <p>Your OTP code is:</p>
          <h1 style="color:#6a1b9a;">${otp}</h1>
          <p>This OTP is valid for 5 minutes.</p>
          <br/>
          <p>If you didn’t request this, please ignore this email.</p>
        </div>
      `,
    };

    await sgMail.send(msg);
    console.log("OTP email sent to:", to);
    return true;
  } catch (error) {
    console.error("SendGrid Error:", error.response?.body || error.message);
    return false;
  }
};
