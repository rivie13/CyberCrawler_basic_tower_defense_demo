# GUT Extension Setup Verification for Cursor

## ✅ What We've Completed
1. **Created `.gutconfig.json`** - Configuration file for GUT extension
2. **Test directories created** - unit, integration, system test folders
3. **Test files ready** - Example tests waiting to be run

## 🔍 Verification Steps

### Step 1: Check Required Extensions
In Cursor, verify you have these extensions installed:
- **GUT** - Godot Unit Test extension
- **Godot Tools** - Required dependency for GUT extension

### Step 2: Verify GUT Extension Configuration
1. Open Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`)
2. Search for "GUT" commands
3. You should see commands like:
   - `GUT: Run All Tests`
   - `GUT: Run Current Test`
   - `GUT: Run Current Script`

### Step 3: Test the Setup
1. Open `tests/unit/test_example.gd`
2. Right-click in the file
3. Look for GUT context menu options
4. Or use Command Palette: `GUT: Run Current Script`

### Step 4: Alternative - Use Godot Editor
If VS Code extension isn't working immediately:
1. Open Godot Editor
2. Go to AssetLib tab
3. Search for "GUT - Godot Unit Testing"
4. Download and install
5. Enable in Project Settings > Plugins
6. Use the GUT panel in Godot Editor

## 🚀 Running Your First Test

### Option A: Using Cursor/VS Code
```bash
# Command Palette > GUT: Run All Tests
# Or right-click test file > Run GUT Tests
```

### Option B: Using Terminal
```bash
# Navigate to project directory
cd cybercrawler_basictowerdefense

# Run tests using Godot command line (requires GUT installed in Godot)
godot --headless --script addons/gut/gut_cmdln.gd -gdir=tests/unit -gexit
```

### Option C: Using Godot Editor
1. Open project in Godot
2. Install GUT from AssetLib if not already installed
3. Enable GUT plugin
4. Use GUT panel at bottom of editor
5. Set test directories: tests/unit, tests/integration, tests/system
6. Click "Run All"

## 🔧 Troubleshooting

### Issue: GUT commands not appearing
**Solution**: Install both GUT and Godot Tools extensions

### Issue: "GutTest not found" error
**Solution**: Install GUT plugin in Godot Editor first:
1. Open Godot Editor
2. AssetLib > Search "GUT" > Install
3. Project Settings > Plugins > Enable GUT

### Issue: Tests not discovered
**Solution**: Check file naming:
- Test files must start with `test_`
- Test functions must start with `test_`
- Test files must extend `GutTest`

### Issue: Extension not finding Godot
**Solution**: Configure Godot path in Cursor:
1. Open Settings (`Ctrl+,`)
2. Search for "godot"
3. Set "Godot Tools: Editor Path" to your Godot executable

## 📋 Quick Test Checklist

- [ ] GUT extension installed in Cursor
- [ ] Godot Tools extension installed in Cursor  
- [ ] `.gutconfig.json` file created ✅
- [ ] Test directories exist ✅
- [ ] Test files created ✅
- [ ] GUT commands visible in Command Palette
- [ ] First test runs successfully

## 🎯 Next Steps After Verification

Once you can run the basic `test_example.gd` successfully:

1. **Run Example Test**: Start with `tests/unit/test_example.gd`
2. **Fix Any Issues**: Address any setup problems
3. **Run Game Manager Tests**: Test your actual game code
4. **Add More Tests**: Expand coverage to prevent regressions

## 💡 Tips for Success

- **Start Small**: Run `test_example.gd` first to verify setup
- **Use Descriptive Names**: Test names should explain what they verify
- **Test One Thing**: Each test should verify one specific behavior
- **Run Often**: Run tests frequently during development
- **Watch for Failures**: Failed tests indicate potential issues

## 📞 If You Need Help

If you encounter issues:
1. Check the GUT extension documentation
2. Verify Godot Tools extension is properly configured
3. Try running tests directly in Godot Editor as fallback
4. Check that test files follow naming conventions

---

**Status**: Ready for first test run
**Next Action**: Run `test_example.gd` to verify setup works
**Expected Result**: All tests in test_example.gd should pass 