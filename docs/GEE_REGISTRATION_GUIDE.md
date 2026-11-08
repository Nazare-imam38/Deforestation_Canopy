# Google Earth Engine Project Registration Guide

## Error Message
```
Project ee-imamsyed716 is not registered to use Earth Engine
```

## What This Means
Your Google account is authenticated, but your Google Cloud project needs to be registered/enabled for Earth Engine access.

## Solution: Register Your Project

### Step 1: Visit the Registration Page

Click this link (it's specific to your project):
**https://console.cloud.google.com/earth-engine/configuration?project=ee-imamsyed716**

Or follow these steps:

### Step 2: Manual Registration Steps

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/earth-engine
   - Sign in with the same Google account you used for authentication

2. **Enable Earth Engine API:**
   - In the Google Cloud Console, go to "APIs & Services" → "Library"
   - Search for "Earth Engine API"
   - Click "Enable"

3. **Register for Earth Engine:**
   - Go to: https://earthengine.google.com/
   - Click "Sign Up" or "Get Started"
   - Choose your use case:
     - **Noncommercial use** (for research, education, personal projects)
     - **Commercial use** (for business applications)

4. **Complete Registration:**
   - Fill out the registration form
   - For noncommercial use, you may need to verify eligibility
   - Accept terms and conditions
   - Submit the form

5. **Wait for Approval:**
   - Noncommercial: Usually approved within 24-48 hours
   - Commercial: May take longer, requires additional verification

### Step 3: After Registration

Once your project is registered and approved:

1. **Try authentication again:**
   ```r
   source("scripts/authenticate_gee.R")
   ```

2. **Or re-initialize:**
   ```r
   library(rgee)
   ee_Initialize(drive = TRUE)
   ```

## Quick Links

- **Earth Engine Home:** https://earthengine.google.com/
- **Your Project Console:** https://console.cloud.google.com/earth-engine/configuration?project=ee-imamsyed716
- **Registration Form:** https://earthengine.google.com/signup/
- **Access Guide:** https://developers.google.com/earth-engine/guides/access

## Common Issues

### Issue: "Project not found"
- **Solution:** Make sure you're signed in with the correct Google account
- The project name `ee-imamsyed716` is auto-generated from your email

### Issue: "Already registered but still getting error"
- **Solution:** 
  1. Wait a few minutes for changes to propagate
  2. Clear browser cache
  3. Try re-authenticating

### Issue: "Noncommercial access lost"
- **Solution:** Re-verify your eligibility at:
  https://developers.google.com/earth-engine/guides/access#configuring_noncommercial_access

## For Research/Academic Use

If you're using this for research or academic purposes:

1. Select "Noncommercial use" during registration
2. Provide your institution/affiliation
3. Describe your research project
4. Approval is usually faster for academic use

## After Registration

Once registered, you won't need to do this again. Your project will have permanent access to Earth Engine (as long as you follow the terms of service).

---

**Next Steps:** After registration is approved, run `source("scripts/authenticate_gee.R")` again.

