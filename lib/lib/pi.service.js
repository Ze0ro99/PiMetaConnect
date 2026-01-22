import axios from "axios";
import { piConfig } from "./pi.config.js";

export async function verifyPiPayment(paymentId) {
  const res = await axios.get(
    `${piConfig.baseUrl}/v2/payments/${paymentId}`,
    {
      headers: {
        Authorization: `Bearer ${piConfig.accessToken}`,
      },
    }
  );
  return res.data;
}
