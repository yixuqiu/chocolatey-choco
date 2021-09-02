# Copyright © 2017 - 2021 Chocolatey Software, Inc.
# Copyright © 2015 - 2017 RealDimensions Software, LLC
# Copyright © 2011 - 2015 RealDimensions Software, LLC & original authors/contributors from https://github.com/chocolatey/chocolatey
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$helpersPath = (Split-Path -parent $MyInvocation.MyCommand.Definition);

$global:DebugPreference = "SilentlyContinue"
if ($env:ChocolateyEnvironmentDebug -eq 'true') { $global:DebugPreference = "Continue"; }
$global:VerbosePreference = "SilentlyContinue"
if ($env:ChocolateyEnvironmentVerbose -eq 'true') { $global:VerbosePreference = "Continue"; $verbosity = $true }

$installArguments = $env:chocolateyInstallArguments

$overrideArgs = $false
if ($env:chocolateyInstallOverride -eq 'true') { $overrideArgs = $true }

$forceX86 = $false
if ($env:chocolateyForceX86 -eq 'true') { $forceX86 = $true }

$packageParameters = $env:chocolateyPackageParameters

# ensure module loading preference is on
$PSModuleAutoLoadingPreference = "All";

Write-Debug "Host version is $($host.Version), PowerShell Version is '$($PSVersionTable.PSVersion)' and CLR Version is '$($PSVersionTable.CLRVersion)'."

# grab functions from files
Get-Item $helpersPath\functions\*.ps1 |
  ? { -not ($_.Name.Contains(".Tests.")) } |
    % {
    . $_.FullName;
    #Export-ModuleMember -Function $_.BaseName
    }

# Export built-in functions prior to loading extensions so that
# extension-specific loading behavior can be used based on built-in
# functions. This allows those overrides to be much more deterministic
# This behavior was broken from v0.9.9.5 - v0.10.3.
Export-ModuleMember -Function * -Alias * -Cmdlet *

$currentAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies()

# load extensions if they exist
$extensionsPath = Join-Path "$helpersPath" '..\extensions'
if (Test-Path $extensionsPath) {

    $licensedExtensionPath = Join-Path $extensionsPath -ChildPath 'chocolatey\chocolatey.licensed.dll'
    if (Test-Path $licensedExtensionPath) {
        Write-Debug "Importing '$licensedExtensionPath'"
        Write-Debug "Loading 'chocolatey.licensed' extension"

        # Attempt to import module via already-loaded assembly
        $licensedAssembly = $currentAssemblies |
            Where-Object { $_.GetName().Name -eq 'chocolatey.licensed' } |
            Select-Object -First 1
        if ($licensedAssembly) {
            # already loaded, just import the existing assembly as a module
            Import-Module $licensedAssembly
        }
        else {
            # Fallback: load the extension DLL from the path directly.
            Import-Module $licensedExtensionPath
        }
    }

  Write-Debug 'Loading community extensions'
  Get-ChildItem $extensionsPath -recurse -filter "*.psm1" | Select -ExpandProperty FullName | % { Write-Debug "Importing `'$_`'"; Import-Module $_; }
}

# todo: explore removing this for a future version
Export-ModuleMember -Function * -Alias * -Cmdlet *
