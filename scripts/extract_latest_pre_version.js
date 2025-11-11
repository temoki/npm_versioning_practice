//
// Script to extract and display the latest version from JSON string
// returned by `npm view {package} version --json`
//
// Usage: node extract_latest_pre_version.js '<json_string>'
//
// Input/Output examples:
// =============================================================
// Example 1 - Single version string:
// Input: "1.0.0"
// Output: 1.0.0
//
// Example 2 - Array of versions:
// Input: '["1.0.0", "1.1.0", "0.9.0"]'
// Output: 1.1.0
//
// Example 3 - Empty array:
// Input: '[]'
// Output: (no output, exits with code 0)
//
// Example 4 - Object (no versions):
// Input: '{}'
// Output: (no output, exits with code 0)
//
// Example 5 - Pre-release versions:
// Input: '["1.0.0-dev.3", "1.0.0-dev.1"]'
// Output: 1.0.0-dev.3
// =============================================================
const semver = require('semver');

if (process.argv.length < 3) {
    console.error('Usage: node extract_latest_pre_version.js {JSON String}');
    process.exit(1);
}

const jsonString = process.argv[2];
let json;
try {
    json = JSON.parse(jsonString);
} catch (_) {
    json = jsonString;
}

if (Array.isArray(json)) {
    const versions = json;
    if (versions.length === 0) {
        // No versions
        process.exit(0);
    }
    versions.sort((v1, v2) => {
        return semver.rcompare(v1, v2);
    });
    const latest = semver.valid(versions[0]);
    if (latest !== null) {
        console.log(latest);
    }
    process.exit(0);
}

if (typeof json === 'object' && json !== null) {
    // No versions
    process.exit(0);
}

const latest = semver.valid(json);
if (latest !== null) {
    console.log(latest);
}
process.exit(0);
