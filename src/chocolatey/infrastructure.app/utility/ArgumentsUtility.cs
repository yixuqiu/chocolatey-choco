﻿// Copyright © 2017 - 2021 Chocolatey Software, Inc
// Copyright © 2011 - 2017 RealDimensions Software, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
//
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

using System;

namespace chocolatey.infrastructure.app.utility
{
    //todo: #2560 maybe find a better name/location for this

    public static class ArgumentsUtility
    {
        public static bool SensitiveArgumentsProvided(string commandArguments)
        {
            //todo: #2561 this check is naive, we should switch to regex
            //this picks up cases where arguments are passed with '-' and '--'
            return commandArguments.ContainsSafe("-install-arguments-sensitive")
             || commandArguments.ContainsSafe("-package-parameters-sensitive")
             || commandArguments.ContainsSafe("apikey ")
             || commandArguments.ContainsSafe("config ")
             || commandArguments.ContainsSafe("push ") // push can be passed w/out parameters, it's fine to log it then
             || commandArguments.ContainsSafe("-p ")
             || commandArguments.ContainsSafe("-p=")
             || commandArguments.ContainsSafe("-password")
             || commandArguments.ContainsSafe("-cp ")
             || commandArguments.ContainsSafe("-cp=")
             || commandArguments.ContainsSafe("-certpassword")
             || commandArguments.ContainsSafe("-k ")
             || commandArguments.ContainsSafe("-k=")
             || commandArguments.ContainsSafe("-key ")
             || commandArguments.ContainsSafe("-key=")
             || commandArguments.ContainsSafe("-apikey")
             || commandArguments.ContainsSafe("-api-key")
             || commandArguments.ContainsSafe("-u ")
             || commandArguments.ContainsSafe("-u=")
             || commandArguments.ContainsSafe("-user ")
             || commandArguments.ContainsSafe("-user=")
            ;
        }

#pragma warning disable IDE0022, IDE1006
        [Obsolete("This overload is deprecated and will be removed in v3.")]
        public static bool arguments_contain_sensitive_information(string commandArguments)
            => SensitiveArgumentsProvided(commandArguments);
#pragma warning restore IDE0022, IDE1006
    }
}
