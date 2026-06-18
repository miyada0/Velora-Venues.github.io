/**
 * ✅ NULL SAFETY MIDDLEWARE
 * Ensures critical fields in responses have defaults (not null)
 * Minimal, non-invasive approach - only fixes critical fields
 */

module.exports = (req, res, next) => {
  // Store the original json method
  const originalJson = res.json.bind(res);

  // Override res.json to ensure null-safety
  res.json = function (data) {
    try {
      if (data && typeof data === "object") {
        // If it's an array (multiple items)
        if (Array.isArray(data)) {
          data = data.map((item) => {
            if (item && typeof item === "object") {
              return fixNullFields(item);
            }
            return item;
          });
        } else {
          // If it's a single object, fix null fields
          data = fixNullFields(data);
        }
      }

      return originalJson(data);
    } catch (error) {
      // If sanitization fails, just return the original data
      console.error("❌ Null safety middleware error:", error.message);
      return originalJson(data);
    }
  };

  next();
};

/**
 * Fix critical null fields in an object - MINIMAL approach
 * Only converts null to default, doesn't restructure the object
 */
function fixNullFields(obj) {
  if (!obj || typeof obj !== "object") {
    return obj;
  }

  // Only fix top-level null fields, don't deep clone
  if (obj.price === null || obj.price === undefined) obj.price = 0;
  if (obj.capacity === null || obj.capacity === undefined) obj.capacity = 0;
  if (obj.rating === null || obj.rating === undefined) obj.rating = 0;
  if (obj.amount === null || obj.amount === undefined) obj.amount = 0;
  if (obj.totalAmount === null || obj.totalAmount === undefined) obj.totalAmount = 0;
  if (obj.advanceAmount === null || obj.advanceAmount === undefined) obj.advanceAmount = 0;
  if (obj.numberOfGuests === null || obj.numberOfGuests === undefined) obj.numberOfGuests = 0;
  if (obj.totalRevenue === null || obj.totalRevenue === undefined) obj.totalRevenue = 0;

  // Fix array fields
  if (!Array.isArray(obj.images) || obj.images === null) obj.images = [];
  if (!Array.isArray(obj.facilities) || obj.facilities === null) obj.facilities = [];

  // Fix string fields
  if (obj.description === null || obj.description === undefined) obj.description = "";
  if (obj.status === null || obj.status === undefined) obj.status = "approved";

  return obj;
}
