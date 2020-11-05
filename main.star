#!/usr/bin/env lucicfg

# Copyright (c) 2019 The Dart project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Use ./main.star to regenerate the Luci configuration based on this file.
#
# Documentation for lucicfg is here:
# https://chromium.googlesource.com/infra/luci/luci-go/+/master/lucicfg/doc/
"""
Generates the Luci configuration for the Dart project.
"""

load("//defaults.star", "defaults")

lucicfg.check_version("1.17.0")

DART_GIT = "https://dart.googlesource.com/sdk"
DART_GERRIT = "https://dart-review.googlesource.com/"

GOMA_RBE = {
    "server_host": "goma.chromium.org",
    "use_luci_auth": True,
}

RELEASE_CHANNELS = ["beta", "dev", "stable"]
CHANNELS = RELEASE_CHANNELS + ["try"]
BRANCHES = ["master"] + RELEASE_CHANNELS

TEST_PY_PATHS = "pkg/(async_helper|expect|smith|status_file|test_runner)/.+"

STANDARD_PATHS = [
    "DEPS",  # DEPS catches most third_party changes.
    # build files
    "build/.+",
    "BUILD.gn",
    "sdk_args.gni",
    # core libraries
    ".dart_tool/package_config.json",
    "sdk/.+",
    # testing
    TEST_PY_PATHS,
    "tools/bots/test_matrix.json",
    # tests
    "tests/.+",
]

CFE_PATHS_ONLY = [
    "pkg/(front_end|kernel|testing|_fe_analyzer_shared)/.+",
]

CFE_PATHS = STANDARD_PATHS + CFE_PATHS_ONLY

VM_PATHS = CFE_PATHS + [
    # VM sources
    "pkg/vm/.+",
    "runtime/.+",
]

DART2JS_PATHS = CFE_PATHS + [
    # compiler sources
    "pkg/(compiler|dart2js_tools|js_ast)/.+",
    "utils/compiler/.+",
    # testing
    "pkg/(js|modular_test|sourcemap_testing)/.+",
]

DDC_PATHS = CFE_PATHS + [
    # compiler sources
    "pkg/(build_integration|dev_compiler|meta)/.+",
    "utils/dartdevc/.+",
    # testing
    "pkg/(js|modular_test|sourcemap_testing)/.+",
]

ANALYZER_NNBD_PATHS = STANDARD_PATHS + [
    # analyzer sources
    "pkg/(analyzer|analyzer_cli|_fe_analyzer_shared)/.+",
]

ANALYZER_PATHS = STANDARD_PATHS + [
    # "analyzer" bots analyze everything under pkg
    "pkg/.+",
]

# Priorities used by the swarming scheduler. The higher the number, the lower
# the priority.
LOW = 70  # Used for "FYI" post-submit builds.
NORMAL = 50  # Used for post-submit builds.
HIGH = 30  # Used for try-jobs.
HIGHEST = 25  # Used for shards in the recipes, included here for completeness.

CHROME = {"custom_vars": {"download_chrome": True}}
FIREFOX = {"custom_vars": {"download_firefox": True}}

def to_location_regexp(paths):
    return [".+/[+]/%s" % path for path in paths]

def mac():
    return {"os": "Mac"}

def windows():
    return {"os": "Windows"}

CI_ACCOUNT = "dart-luci-ci-builder@dart-ci.iam.gserviceaccount.com"
TRY_ACCOUNT = "dart-luci-try-builder@dart-ci.iam.gserviceaccount.com"
CI_TRIGGERERS = ["luci-scheduler@appspot.gserviceaccount.com", CI_ACCOUNT]
ROLL_TRIGGERERS = {
    "users": [
        "luci-scheduler@appspot.gserviceaccount.com",
        CI_ACCOUNT,
    ],
    "groups": ["project-dart-roller-owners"],
}
CI_SANDBOX_TRIGGERERS = CI_TRIGGERERS + [TRY_ACCOUNT]

lucicfg.config(
    config_dir = ".",
    tracked_files = [
        "commit-queue.cfg",
        "cr-buildbucket.cfg",
        "luci-logdog.cfg",
        "luci-milo.cfg",
        "luci-notify.cfg",
        "luci-scheduler.cfg",
        "project.cfg",
    ],
    lint_checks = ["default"],
)

luci.project(
    name = "dart",
    buildbucket = "cr-buildbucket.appspot.com",
    logdog = "luci-logdog.appspot.com",
    milo = "luci-milo.appspot.com",
    notify = "luci-notify.appspot.com",
    scheduler = "luci-scheduler.appspot.com",
    swarming = "chromium-swarm.appspot.com",
    acls = [
        acl.entry(
            [
                acl.BUILDBUCKET_READER,
                acl.LOGDOG_READER,
                acl.PROJECT_CONFIGS_READER,
                acl.SCHEDULER_READER,
            ],
            groups = ["all"],
        ),
        acl.entry(acl.LOGDOG_WRITER, groups = ["luci-logdog-chromium-writers"]),
        acl.entry(
            [acl.SCHEDULER_OWNER, acl.BUILDBUCKET_TRIGGERER],
            groups = ["project-dart-admins"],
        ),
        acl.entry(acl.CQ_COMMITTER, groups = ["project-dart-committers"]),
        acl.entry(acl.CQ_DRY_RUNNER, groups = ["project-dart-tryjob-access"]),
    ],
)

luci.milo(
    logo = "https://storage.googleapis.com/chrome-infra-public/logo/dartlang.png",
)

luci.console_view(
    name = "be",
    repo = "https://dart.googlesource.com/sdk",
    title = "SDK Bleeding Edge Console",
    refs = ["refs/heads/master"],
    header = "console-header.textpb",
)

luci.console_view(
    name = "alt",
    repo = "https://dart.googlesource.com/sdk",
    title = "SDK Bleeding Edge Console (alternative)",
    refs = ["refs/heads/master"],
    header = "console-header.textpb",
)

luci.console_view(
    name = "dev",
    repo = "https://dart.googlesource.com/sdk",
    title = "SDK Dev Console",
    refs = ["refs/heads/dev"],
    header = "console-header.textpb",
)

luci.console_view(
    name = "beta",
    repo = "https://dart.googlesource.com/sdk",
    title = "SDK Beta Console",
    refs = ["refs/heads/beta"],
    header = "console-header.textpb",
)

luci.console_view(
    name = "stable",
    repo = "https://dart.googlesource.com/sdk",
    title = "SDK Stable Console",
    refs = ["refs/heads/stable"],
    header = "console-header.textpb",
)

luci.console_view(
    name = "flutter",
    repo = DART_GIT,
    title = "Dart/Flutter Console",
    refs = ["refs/heads/master"],
)

luci.console_view(
    name = "flutter-hhh",
    repo = "https://dart.googlesource.com/linear_sdk_flutter_engine",
    title = "Dart/Flutter Linear History Console",
    refs = ["refs/heads/master"],
)

luci.console_view(
    name = "fyi",
    repo = DART_GIT,
    title = "SDK FYI Console",
    refs = ["refs/heads/master"],
)

luci.list_view(
    name = "cq",
    title = "SDK CQ Console",
)

luci.list_view(
    name = "infra",
    title = "Infra Console",
)

luci.logdog(gs_bucket = "chromium-luci-logdog")

luci.bucket(
    name = "ci",
    acls = [
        acl.entry(acl.BUILDBUCKET_TRIGGERER, users = CI_TRIGGERERS),
    ],
)
luci.bucket(
    name = "ci.roll",
    acls = [
        acl.entry(acl.BUILDBUCKET_TRIGGERER, **ROLL_TRIGGERERS),
    ],
)
luci.bucket(
    name = "ci.sandbox",
    acls = [
        acl.entry(acl.BUILDBUCKET_TRIGGERER, users = CI_SANDBOX_TRIGGERERS),
    ],
)
TRY_ACLS = [
    acl.entry(
        acl.BUILDBUCKET_TRIGGERER,
        groups = ["project-dart-tryjob-access", "service-account-cq"],
    ),
]
luci.bucket(name = "try", acls = TRY_ACLS)  # Tryjobs specific to the Dart SDK repo.
luci.bucket(name = "try.shared", acls = TRY_ACLS)  # Tryjobs for all repos.

luci.gitiles_poller(
    name = "dart-gitiles-trigger-flutter",
    bucket = "ci",
    repo = "https://dart.googlesource.com/linear_sdk_flutter_engine/",
    refs = ["refs/heads/master"],
)

luci.gitiles_poller(
    name = "dart-ci-test-data-trigger",
    bucket = "ci",
    path_regexps = ["tools/bots/ci_test_data_trigger"],
    repo = DART_GIT,
    refs = ["refs/heads/ci-test-data"],
)

def dart_poller(name, bucket = "ci", branches = BRANCHES, paths = None):
    for branch in branches:
        luci.gitiles_poller(
            name = "%s-%s" % (name, branch),
            bucket = bucket,
            path_regexps = paths,
            repo = DART_GIT,
            refs = ["refs/heads/%s" % branch],
        )

dart_poller("dart-gitiles-trigger", branches = BRANCHES)
dart_poller("dart-vm-gitiles-trigger", branches = ["master"], paths = VM_PATHS)

luci.gitiles_poller(
    name = "dart-flutter-engine-trigger",
    bucket = "ci",
    repo = "https://dart.googlesource.com/external/github.com/flutter/engine",
    refs = ["refs/heads/master"],
)

luci.gitiles_poller(
    name = "dart-flutter-flutter-trigger",
    bucket = "ci",
    repo = "https://dart.googlesource.com/external/github.com/flutter/flutter",
    refs = ["refs/heads/master"],
)

luci.notifier(
    name = "infra",
    on_new_failure = True,
    notify_emails = [
        "athom@google.com",
        "sortie@google.com",
        "whesse@google.com",
        "karlklose@google.com",
    ],
)

luci.notifier(
    name = "dart",
    on_new_failure = True,
    notify_emails = ["athom@google.com"],
    notify_blamelist = True,
)

luci.notifier(
    name = "nightly",
    on_new_failure = True,
    notify_emails = ["karlklose@google.com", "athom@google.com"],
)

luci.notifier(
    name = "dart-fuzz-testing",
    on_success = True,
    on_failure = True,
    notify_emails = ["ajcbik@google.com", "athom@google.com"],
)

luci.notifier(
    name = "frontend-team",
    on_failure = True,
    notify_emails = ["jensj@google.com"],
)

luci.notifier(
    name = "ci-test-data",
    on_success = True,
    on_failure = True,
    notify_emails = ["karlklose@google.com"],
)

luci.cq(
    submit_max_burst = 2,
    submit_burst_delay = 8 * time.minute,
)

def default_verifiers():
    return [
        luci.cq_tryjob_verifier(
            builder = "presubmit-try",
            disable_reuse = True,
        ),
    ]

luci.cq_group(
    name = "sdk",
    watch = cq.refset(
        DART_GERRIT + "sdk",
        refs = ["refs/heads/%s" % branch for branch in BRANCHES],
    ),
    allow_submit_with_open_deps = True,
    tree_status_host = "dart-status.appspot.com",
    retry_config = cq.RETRY_NONE,
    verifiers = None,
)

luci.cq_group(
    name = "sdk-infra-config",
    watch = cq.refset(DART_GERRIT + "sdk", refs = ["refs/heads/infra/config"]),
    allow_submit_with_open_deps = True,
    tree_status_host = "dart-status.appspot.com",
    retry_config = cq.RETRY_NONE,
    verifiers = default_verifiers(),
)

luci.cq_group(
    name = "recipes",
    watch = cq.refset(DART_GERRIT + "recipes", refs = ["refs/heads/master"]),
    allow_submit_with_open_deps = True,
    tree_status_host = "dart-status.appspot.com",
    retry_config = cq.RETRY_NONE,
    verifiers = default_verifiers(),
)

luci.cq_group(
    name = "dart_ci",
    watch = cq.refset(DART_GERRIT + "dart_ci", refs = ["refs/heads/master"]),
    allow_submit_with_open_deps = True,
    tree_status_host = "dart-status.appspot.com",
    retry_config = cq.RETRY_NONE,
    verifiers = None,
)

def dart_recipe(name):
    return luci.recipe(
        name = name,
        cipd_package = "dart/recipe_bundles/dart.googlesource.com/recipes",
    )

def with_goma_rbe(goma_rbe, channel, dimensions, properties):
    """Sets the $build/goma property when goma on RBE is used.

    Args:
        goma_rbe: Opt-in (True), opt-out (False) or default (None).
        channel: The channel of the builder.
        dimensions: The dimensions of the builder.
        properties: The properties object to set $build/goma on (if opted-in).

    Returns:
        A copy of the properties with GOMA on RBE properties set if applicable.
    """
    if goma_rbe in (None, True):
        goma_properties = {}
        goma_properties.update(GOMA_RBE)
        goma_properties["enable_ats"] = dimensions["os"] != "Mac"
        updated_properties = dict(properties)
        updated_properties.setdefault("$build/goma", goma_properties)
        return updated_properties
    return properties

def dart_try_builder(
        name,
        recipe = "dart/neo",
        bucket = "try",
        dimensions = None,
        execution_timeout = None,
        experiment_percentage = None,
        goma_rbe = None,
        location_regexp = None,
        properties = None,
        on_cq = False):
    """Creates a Dart tryjob.

    Args:
        name: The builder name.
        recipe: The recipe to use (defaults to "dart/neo").
        bucket: The bucket to use (defaults to "try").
        dimensions: Extra swarming dimensions required by this builder.
        execution_timeout: Time to allow for the build to run.
        experiment_percentage: What experiment percentage to use.
        goma_rbe: Whether to use goma on RBE or not.
        location_regexp: Locations that trigger this tryjob.
        properties: Extra properties to set for builds.
        on_cq: Whether the build is added to the default set of CQ tryjobs.
    """
    if on_cq and location_regexp:
        fail("Can't be on the default CQ and conditionally on the CQ")
    dimensions = defaults.dimensions(dimensions)
    dimensions["pool"] = "luci.dart.try"
    properties = defaults.properties(properties)
    builder_properties = with_goma_rbe(goma_rbe, "try", dimensions, properties)
    builder = name + "-try"

    luci.builder(
        name = builder,
        build_numbers = True,
        bucket = bucket,
        caches = [swarming.cache("third_party/browsers", name = "browsers")],
        dimensions = dimensions,
        executable = dart_recipe(recipe),
        execution_timeout = execution_timeout,
        priority = HIGH,
        properties = builder_properties,
        service_account = TRY_ACCOUNT,
        swarming_tags = ["vpython:native-python-wrapper"],
    )
    includable_only = (not on_cq and not experiment_percentage and
                       not location_regexp)
    luci.cq_tryjob_verifier(
        builder = builder,
        cq_group = "sdk",
        experiment_percentage = experiment_percentage,
        location_regexp = location_regexp,
        includable_only = includable_only,
    )
    luci.list_view_entry(list_view = "cq", builder = builder)

postponed_alt_console_entries = []

# Global builder defaults
luci.builder.defaults.properties.set({
    "$recipe_engine/isolated": {
        "server": "https://isolateserver.appspot.com",
    },
    "$recipe_engine/swarming": {
        "server": "https://chromium-swarm.appspot.com",
    },
})

lkgr_builders = []

def dart_builder(
        name,
        bucket,
        recipe = "dart/neo",
        enabled = True,
        category = None,
        channels = [],
        dimensions = None,
        executable = None,
        execution_timeout = None,
        expiration_timeout = None,
        goma_rbe = None,
        fyi = False,
        notifies = "dart",
        priority = NORMAL,
        properties = None,
        schedule = "triggered",
        service_account = TRY_ACCOUNT,
        triggered_by = ["dart-gitiles-trigger-%s"],
        triggering_policy = None,
        on_cq = False,
        experiment_percentage = None,
        location_regexp = None,
        lkgr = False):
    """
    Creates a Dart builder on all the specified channels.

    Args:
        name: The builder name.
        bucket: The bucket to use (defaults to "try").
        recipe: The recipe to use (defaults to "dart/neo").
        enabled: Whether this builder is currently running or not.
        category: Where to show the builder on the console.
        channels: Which other channels the builder should be added to.
        dimensions: Extra swarming dimensions required by this builder.
        executable: The Luci executable to use.
        execution_timeout: Time to allow for the build to run.
        expiration_timeout: How long builds should wait for a bot to run on.
        goma_rbe: Whether to use goma on RBE or not.
        fyi: Whether this is an FYI builder or not.
        notifies: Which luci notifier group to notify (default: "dart").
        priority: What swarming priority this builder gets (default: NORMAL).
        properties: Extra properties to set for builds.
        schedule: What schedule to use (default: "triggered").
        service_account: The task service account to use (default: TRY_ACCOUNT).
        triggered_by: What triggers this builder (defaults to standard trigger).
        triggering_policy: The triggering policy used by this builder.
        on_cq: Whether the build is added to the default set of CQ tryjobs.
        experiment_percentage: What experiment percentage to use.
        location_regexp: Locations that trigger this builder.
        lkgr: If true, this builder needs to be green to advance the LKGR.
    """
    dimensions = defaults.dimensions(dimensions)
    properties = defaults.properties(properties)

    os = dimensions["os"]
    if "win" in name and os != "Windows":
        fail("builder %s should be a Windows builder" % name)
    if "mac" in name and os != "Mac":
        fail("builder %s should be a macOS builder" % name)
    if "linux" in name and os != "Linux":
        fail("builder %s should be a Linux builder" % name)

    if lkgr:
        lkgr_builders.append({"project": "dart", "bucket": bucket, "builder": name})

    def builder(channel, triggered_by):
        if channel == "try":
            dart_try_builder(
                name,
                recipe = recipe,
                dimensions = dimensions,
                properties = properties,
                on_cq = on_cq,
                execution_timeout = execution_timeout,
                experiment_percentage = experiment_percentage,
                goma_rbe = goma_rbe,
                location_regexp = location_regexp,
            )
        else:
            builder_properties = with_goma_rbe(
                goma_rbe,
                channel,
                dimensions,
                properties,
            )
            builder = name + "-" + channel if channel else name
            branch = channel if channel else "master"
            if schedule == "triggered" and triggered_by:
                triggered_by = [
                    trigger.replace("%s", branch)
                    for trigger in triggered_by
                ]
                if channel in RELEASE_CHANNELS:
                    # Always run vm builders on release channels.
                    triggered_by = [
                        trigger.replace("dart-vm-", "dart-")
                        for trigger in triggered_by
                    ]
            luci.builder(
                name = builder,
                build_numbers = True,
                bucket = bucket,
                caches = [swarming.cache("browsers")],
                dimensions = dimensions,
                executable = executable or dart_recipe(recipe),
                execution_timeout = execution_timeout,
                expiration_timeout = expiration_timeout,
                priority = priority,
                properties = builder_properties,
                notifies = [notifies] if notifies and not channel and enabled else None,
                schedule = schedule if enabled else None,
                service_account = service_account,
                swarming_tags = ["vpython:native-python-wrapper"],
                triggered_by = triggered_by if enabled else None,
                triggering_policy = triggering_policy,
            )
            if category:
                console_category, _, short_name = category.rpartition("|")
                toplevel_category, _, _ = console_category.partition("|")
                console = channel or "be" if not fyi else "fyi"
                luci.console_view_entry(
                    builder = builder,
                    short_name = short_name,
                    category = console_category,
                    console_view = console,
                )
                if console == "be":
                    if toplevel_category == "vm":
                        postponed_alt_console_entries.append({
                            "builder": builder,
                            "short_name": short_name,
                            "category": console_category,
                        })
                    else:
                        luci.console_view_entry(
                            builder = builder,
                            short_name = short_name,
                            category = console_category,
                            console_view = "alt",
                        )

    builder(None, triggered_by = triggered_by)
    for channel in channels:
        if enabled:
            builder(channel, triggered_by = triggered_by)

def dart_ci_builder(name, bucket = "ci", dimensions = {}, **kwargs):
    dimensions.setdefault("pool", "luci.dart.ci")
    dart_builder(
        name,
        bucket = bucket,
        dimensions = dimensions,
        service_account = CI_ACCOUNT,
        **kwargs
    )

def dart_ci_sandbox_builder(name, channels = CHANNELS, **kwargs):
    dart_builder(
        name,
        bucket = "ci.sandbox",
        channels = channels,
        service_account = TRY_ACCOUNT,
        **kwargs
    )

def dart_infra_builder(name, notifies = "infra", triggered_by = None, **kwargs):
    dart_ci_builder(
        name,
        notifies = notifies,
        triggered_by = triggered_by,
        **kwargs
    )
    luci.list_view_entry(list_view = "infra", builder = name)

def dart_vm_extra_builder(name, on_cq = False, location_regexp = None, **kwargs):
    """
    Creates a Dart builder that is only triggered by VM commits.

    Args:
        name: The builder name.
        on_cq: Whether the build is added to the default set of CQ tryjobs.
        location_regexp: Locations that trigger this builder.
        **kwargs: Extra arguments are passed on to dart_ci_sandbox_builder.
    """
    triggered_by = ["dart-vm-gitiles-trigger-%s"]
    if on_cq and not location_regexp:
        location_regexp = to_location_regexp(VM_PATHS)
        on_cq = False
    dart_ci_sandbox_builder(
        name,
        triggered_by = triggered_by,
        on_cq = on_cq,
        location_regexp = location_regexp,
        **kwargs
    )

def dart_vm_low_priority_builder(name, **kwargs):
    dart_vm_extra_builder(
        name,
        channels = ["try"],
        priority = LOW,
        expiration_timeout = time.day,
        **kwargs
    )

# These lists are used to collect all nightly/weekly builders to give them as
# properties to the "nightly"/"weekly" builder defined below, which triggers
# the actual builds using the "cron" recipe.
#
# We do not set a schedule on the individual builders because the scheduler
# doesn't set an input commit when it triggers cron'ed builders, and without
# an input commit, Milo doesn't know how to show the build on the console.
nightly_builders = []
weekly_builders = []

def nightly_builder(name, notifies = "nightly", **kwargs):
    dart_ci_sandbox_builder(
        name,
        notifies = notifies,
        on_cq = False,
        priority = LOW,
        schedule = "triggered",  # triggered by nightly cron builder
        triggered_by = None,
        **kwargs
    )
    nightly_builders.append(name)

def weekly_ci_sandbox_builder(name, notifies = None, **kwargs):
    dart_ci_sandbox_builder(
        name,
        notifies = notifies,
        on_cq = False,
        priority = LOW,
        schedule = "triggered",  # triggered by weekly cron builder
        triggered_by = None,
        **kwargs
    )
    weekly_builders.append(name)

# cfe
dart_ci_sandbox_builder(
    "front-end-linux-release-x64",
    category = "cfe|l",
    on_cq = True,
)
dart_ci_sandbox_builder(
    "front-end-mac-release-x64",
    category = "cfe|m",
    dimensions = mac(),
)
dart_ci_sandbox_builder(
    "front-end-win-release-x64",
    category = "cfe|w",
    dimensions = windows(),
)
dart_ci_sandbox_builder(
    "front-end-nnbd-linux-release-x64",
    category = "cfe|nnbd|l",
    location_regexp = to_location_regexp(CFE_PATHS),
)
nightly_builder(
    "front-end-nnbd-mac-release-x64",
    category = "cfe|nnbd|m",
    channels = ["try"],
    dimensions = mac(),
)
nightly_builder(
    "front-end-nnbd-win-release-x64",
    category = "cfe|nnbd|w",
    channels = ["try"],
    dimensions = windows(),
)
dart_ci_sandbox_builder(
    "flutter-frontend",
    category = "cfe|fl",
    channels = ["try"],
    notifies = "frontend-team",
    location_regexp = to_location_regexp(CFE_PATHS_ONLY),
)
weekly_ci_sandbox_builder(
    "frontend-weekly",
    notifies = "frontend-team",
    channels = [],
    execution_timeout = 12 * time.hour,
)

# flutter
dart_ci_sandbox_builder(
    "flutter-engine-linux",
    recipe = "dart/flutter_engine",
    category = "flutter|3H",
    channels = ["try"],
    execution_timeout = 8 * time.hour,
    triggered_by = ["dart-gitiles-trigger-flutter"],
    properties = {
        "bisection_enabled": True,
        "flutter_test_suites": [
            "add_to_app_life_cycle_tests",
            "framework_coverage",
            "framework_tests",
            "tool_coverage",
            "tool_tests",
        ],
    },
)

dart_ci_sandbox_builder(
    "flutter-engine-linux-web_tests",
    recipe = "dart/flutter_engine",
    category = "flutter|web",
    channels = ["try"],
    execution_timeout = 8 * time.hour,
    triggered_by = ["dart-gitiles-trigger-flutter"],
    properties = {
        "bisection_enabled": True,
        "flutter_test_suites": ["web_tests"],
    },
)

# vm|nnbd|jit
dart_vm_extra_builder(
    "vm-kernel-nnbd-linux-debug-x64",
    category = "vm|nnbd|jit|d",
    on_cq = True,
)
dart_vm_extra_builder(
    "vm-kernel-nnbd-linux-release-x64",
    category = "vm|nnbd|jit|r",
    on_cq = True,
)
nightly_builder(
    "vm-kernel-nnbd-linux-debug-ia32",
    category = "vm|nnbd|jit|d3",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-nnbd-linux-release-ia32",
    category = "vm|nnbd|jit|r3",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-nnbd-linux-release-simarm",
    category = "vm|nnbd|jit|ra",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-nnbd-linux-release-simarm64",
    category = "vm|nnbd|jit|ra6",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-nnbd-mac-debug-x64",
    category = "vm|nnbd|jit|md",
    channels = ["try"],
    dimensions = mac(),
)
nightly_builder(
    "vm-kernel-nnbd-mac-release-x64",
    category = "vm|nnbd|jit|mr",
    channels = ["try"],
    dimensions = mac(),
)
nightly_builder(
    "vm-kernel-nnbd-win-release-ia32",
    category = "vm|nnbd|jit|wr3",
    channels = ["try"],
    dimensions = windows(),
)
nightly_builder(
    "vm-kernel-nnbd-win-debug-x64",
    category = "vm|nnbd|jit|wd",
    channels = ["try"],
    dimensions = windows(),
)
nightly_builder(
    "vm-kernel-nnbd-win-release-x64",
    category = "vm|nnbd|jit|wr",
    channels = ["try"],
    dimensions = windows(),
)

# vm|nnbd|aot
dart_vm_extra_builder(
    "vm-kernel-precomp-nnbd-linux-release-x64",
    category = "vm|nnbd|aot|r",
)
nightly_builder(
    "vm-kernel-precomp-nnbd-linux-debug-simarm_x64",
    category = "vm|nnbd|aot|da",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-precomp-nnbd-linux-release-simarm_x64",
    category = "vm|nnbd|aot|ra",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-precomp-nnbd-linux-debug-x64",
    category = "vm|nnbd|aot|d",
    channels = ["try"],
    properties = {"shard_timeout": (90 * time.minute) // time.second},
)
nightly_builder(
    "vm-kernel-precomp-nnbd-linux-release-simarm64",
    category = "vm|nnbd|aot|ra6",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-precomp-nnbd-mac-release-simarm64",
    category = "vm|nnbd|aot|ma6",
    channels = ["try"],
    dimensions = mac(),
)
nightly_builder(
    "vm-kernel-precomp-nnbd-win-release-x64",
    category = "vm|nnbd|aot|wr",
    channels = ["try"],
    dimensions = windows(),
)

# vm|app-kernel
dart_vm_extra_builder(
    "app-kernel-linux-debug-x64",
    category = "vm|app-kernel|d64",
)
nightly_builder(
    "app-kernel-linux-product-x64",
    category = "vm|app-kernel|p64",
)
dart_vm_extra_builder(
    "app-kernel-linux-release-x64",
    category = "vm|app-kernel|r64",
)

#vm|kernel
dart_vm_extra_builder(
    "vm-canary-linux-debug",
    category = "vm|kernel|c",
    on_cq = True,
)
dart_ci_sandbox_builder("vm-kernel-linux-debug-x64", category = "vm|kernel|d")
dart_vm_extra_builder(
    "vm-kernel-linux-release-simarm",
    category = "vm|kernel|a32",
)
dart_vm_extra_builder(
    "vm-kernel-linux-release-simarm64",
    category = "vm|kernel|a64",
)
nightly_builder(
    "vm-kernel-linux-release-ia32",
    category = "vm|kernel|r32",
    channels = ["try"],
)
dart_ci_sandbox_builder(
    "vm-kernel-linux-release-x64",
    category = "vm|kernel|r",
    on_cq = True,
)
dart_vm_extra_builder(
    "vm-kernel-checked-linux-release-x64",
    category = "vm|kernel|rc",
)
nightly_builder(
    "vm-kernel-linux-debug-ia32",
    category = "vm|kernel|d32",
    channels = ["try"],
)
dart_ci_sandbox_builder(
    "vm-kernel-mac-debug-x64",
    category = "vm|kernel|md",
    dimensions = mac(),
)
dart_ci_sandbox_builder(
    "vm-kernel-mac-release-x64",
    category = "vm|kernel|mr",
    dimensions = mac(),
    on_cq = True,
    experiment_percentage = 5,
)
nightly_builder(
    "vm-kernel-win-debug-ia32",
    category = "vm|kernel|wd3",
    channels = ["try"],
    dimensions = windows(),
)
dart_ci_sandbox_builder(
    "vm-kernel-win-debug-x64",
    category = "vm|kernel|wd",
    dimensions = windows(),
)
nightly_builder(
    "vm-kernel-win-release-ia32",
    category = "vm|kernel|wr3",
    channels = ["try"],
    dimensions = windows(),
)
dart_ci_sandbox_builder(
    "vm-kernel-win-release-x64",
    category = "vm|kernel|wr",
    dimensions = windows(),
)
dart_vm_extra_builder(
    "cross-vm-linux-release-arm64",
    category = "vm|kernel|cra",
    channels = [],
    properties = {"shard_timeout": (90 * time.minute) // time.second},
)

# vm|kernel-precomp
dart_vm_extra_builder(
    "vm-kernel-precomp-linux-debug-x64",
    category = "vm|kernel-precomp|d",
)
dart_vm_extra_builder(
    "vm-kernel-precomp-linux-product-x64",
    category = "vm|kernel-precomp|p",
)
dart_vm_extra_builder(
    "vm-kernel-precomp-linux-release-simarm",
    category = "vm|kernel-precomp|a32",
)
dart_vm_extra_builder(
    "vm-kernel-precomp-linux-release-simarm64",
    category = "vm|kernel-precomp|a64",
)
dart_vm_extra_builder(
    "vm-kernel-precomp-linux-release-x64",
    category = "vm|kernel-precomp|r",
)
dart_vm_extra_builder(
    "vm-kernel-precomp-obfuscate-linux-release-x64",
    category = "vm|kernel-precomp|o",
)
dart_vm_extra_builder(
    "vm-kernel-precomp-linux-debug-simarm_x64",
    category = "vm|kernel-precomp|adx",
    properties = {"shard_timeout": (90 * time.minute) // time.second},
)
dart_vm_extra_builder(
    "vm-kernel-precomp-linux-release-simarm_x64",
    category = "vm|kernel-precomp|arx",
)
dart_vm_extra_builder(
    "vm-kernel-precomp-mac-release-simarm64",
    category = "vm|kernel-precomp|ma",
    dimensions = mac(),
)
dart_vm_extra_builder(
    "vm-kernel-precomp-win-release-x64",
    category = "vm|kernel-precomp|wr",
    dimensions = windows(),
)
nightly_builder(
    "cross-vm-precomp-linux-release-arm64",
    category = "vm|kernel-precomp|cra",
    channels = [],
    properties = {"shard_timeout": (90 * time.minute) // time.second},
)

# vm|kernel-precomp|android
dart_vm_extra_builder(
    "vm-kernel-precomp-android-release-arm_x64",
    category = "vm|kernel-precomp|android|a32",
    properties = {"shard_timeout": (90 * time.minute) // time.second},
)
dart_vm_extra_builder(
    "vm-kernel-precomp-android-release-arm64",
    category = "vm|kernel-precomp|android|a64",
    properties = {"shard_timeout": (90 * time.minute) // time.second},
)

# vm|product
nightly_builder(
    "vm-kernel-linux-product-x64",
    category = "vm|product|l",
    channels = ["try"],
)
nightly_builder(
    "vm-kernel-mac-product-x64",
    category = "vm|product|m",
    channels = ["try"],
    dimensions = mac(),
)
nightly_builder(
    "vm-kernel-win-product-x64",
    category = "vm|product|w",
    channels = ["try"],
    dimensions = windows(),
)

# vm|misc
nightly_builder(
    "vm-kernel-optcounter-threshold-linux-release-ia32",
    category = "vm|misc|o32",
    channels = ["try"],
)
dart_vm_low_priority_builder(
    "vm-kernel-optcounter-threshold-linux-release-x64",
    category = "vm|misc|o64",
)

def dart_vm_sanitizer_builder(name, **kwargs):
    nightly_builder(
        name,
        channels = ["try"],
        properties = {"bisection_enabled": True},
        **kwargs
    )

dart_vm_sanitizer_builder(
    "vm-kernel-asan-linux-release-x64",
    category = "vm|misc|a",
)
dart_vm_sanitizer_builder(
    "vm-kernel-msan-linux-release-x64",
    category = "vm|misc|m",
)
dart_vm_sanitizer_builder(
    "vm-kernel-tsan-linux-release-x64",
    category = "vm|misc|t",
)
dart_vm_sanitizer_builder(
    "vm-kernel-ubsan-linux-release-x64",
    category = "vm|misc|u",
    goma_rbe = False,
)  # ubsan is not compatible with our sysroot.
dart_vm_sanitizer_builder(
    "vm-kernel-precomp-asan-linux-release-x64",
    category = "vm|misc|aot|a",
)
dart_vm_sanitizer_builder(
    "vm-kernel-precomp-msan-linux-release-x64",
    category = "vm|misc|aot|m",
)
dart_vm_sanitizer_builder(
    "vm-kernel-precomp-tsan-linux-release-x64",
    category = "vm|misc|aot|t",
)
dart_vm_sanitizer_builder(
    "vm-kernel-precomp-ubsan-linux-release-x64",
    category = "vm|misc|aot|u",
    goma_rbe = False,
)  # ubsan is not compatible with our sysroot.
nightly_builder(
    "vm-kernel-reload-linux-debug-x64",
    category = "vm|misc|reload|d",
)
nightly_builder(
    "vm-kernel-reload-linux-release-x64",
    category = "vm|misc|reload|r",
)
nightly_builder(
    "vm-kernel-reload-rollback-linux-debug-x64",
    category = "vm|misc|reload|drb",
)
nightly_builder(
    "vm-kernel-reload-rollback-linux-release-x64",
    category = "vm|misc|reload|rrb",
)
dart_vm_low_priority_builder("vm-fuchsia-release-x64", category = "vm|misc|f")

# vm|ffi
dart_vm_extra_builder("vm-ffi-android-debug-arm", category = "vm|ffi|d32")
dart_vm_extra_builder("vm-ffi-android-release-arm", category = "vm|ffi|r32")
dart_vm_extra_builder("vm-ffi-android-product-arm", category = "vm|ffi|p32")
dart_vm_extra_builder("vm-ffi-android-debug-arm64", category = "vm|ffi|d64")
dart_vm_extra_builder("vm-ffi-android-release-arm64", category = "vm|ffi|r64")
dart_vm_extra_builder("vm-ffi-android-product-arm64", category = "vm|ffi|p64")
dart_vm_extra_builder(
    "vm-precomp-ffi-qemu-linux-release-arm",
    category = "vm|ffi|qe",
)

# pkg
dart_ci_sandbox_builder(
    "pkg-linux-release",
    category = "pkg|l",
    on_cq = True,
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "pkg-mac-release",
    category = "pkg|m",
    dimensions = mac(),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "pkg-win-release",
    category = "pkg|w",
    dimensions = windows(),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "pkg-linux-debug",
    category = "pkg|ld",
    channels = ["try"],
    properties = CHROME,
)

# dart2js
dart_ci_sandbox_builder(
    "dart2js-strong-hostasserts-linux-ia32-d8",
    category = "dart2js|d8|ha",
    location_regexp = to_location_regexp(DART2JS_PATHS),
)
dart_ci_sandbox_builder(
    "dart2js-minified-strong-linux-x64-d8",
    category = "dart2js|d8|mi",
    location_regexp = to_location_regexp(DART2JS_PATHS),
)
dart_ci_sandbox_builder(
    "dart2js-unit-linux-x64-release",
    category = "dart2js|d8|u",
    location_regexp = to_location_regexp(DART2JS_PATHS),
)
dart_ci_sandbox_builder(
    "dart2js-strong-linux-x64-chrome",
    category = "dart2js|chrome|l",
    location_regexp = to_location_regexp(DART2JS_PATHS),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "dart2js-csp-minified-linux-x64-chrome",
    category = "dart2js|chrome|csp",
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "dart2js-strong-mac-x64-chrome",
    category = "dart2js|chrome|m",
    dimensions = mac(),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "dart2js-strong-win-x64-chrome",
    category = "dart2js|chrome|w",
    dimensions = windows(),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "dart2js-nnbd-linux-x64-chrome",
    category = "dart2js|chrome|nn",
    location_regexp = to_location_regexp(DART2JS_PATHS),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "dart2js-strong-linux-x64-firefox",
    category = "dart2js|firefox|l",
    properties = FIREFOX,
)
dart_ci_sandbox_builder(
    "dart2js-strong-win-x64-firefox",
    category = "dart2js|firefox|w",
    dimensions = windows(),
    enabled = False,
    properties = FIREFOX,
)
dart_ci_sandbox_builder(
    "dart2js-strong-mac-x64-safari",
    category = "dart2js|safari|m",
    dimensions = mac(),
)

# analyzer
dart_ci_sandbox_builder(
    "flutter-analyze",
    category = "analyzer|fa",
    channels = ["try"],
    location_regexp = [
        ".+/[+]/DEPS",
        ".+/[+]/pkg/analysis_server/.+",
        ".+/[+]/pkg/analysis_server_client/.+",
        ".+/[+]/pkg/analyzer/.+",
        ".+/[+]/pkg/analyzer_plugin/.+",
        ".+/[+]/pkg/front_end/.+",
        ".+/[+]/pkg/_fe_analyzer_shared/.+",
        ".+/[+]/pkg/meta/.+",
        ".+/[+]/pkg/telemetry/.+",
    ],
    notifies = None,
)
dart_ci_sandbox_builder(
    "analyzer-analysis-server-linux",
    category = "analyzer|as",
    channels = CHANNELS,
    location_regexp = to_location_regexp(ANALYZER_PATHS),
)
dart_ci_sandbox_builder(
    "analyzer-linux-release",
    category = "analyzer|l",
    channels = CHANNELS,
    location_regexp = to_location_regexp(ANALYZER_PATHS),
)
dart_ci_sandbox_builder(
    "analyzer-mac-release",
    category = "analyzer|m",
    channels = CHANNELS,
    dimensions = mac(),
)
dart_ci_sandbox_builder(
    "analyzer-win-release",
    category = "analyzer|w",
    channels = CHANNELS,
    dimensions = windows(),
)

# analyzer|nnbd
dart_ci_sandbox_builder(
    "analyzer-nnbd-linux-release",
    category = "analyzer|nnbd|l",
    location_regexp = to_location_regexp(ANALYZER_NNBD_PATHS),
    channels = CHANNELS,
)
nightly_builder(
    "analyzer-nnbd-mac-release",
    category = "analyzer|nnbd|m",
    channels = ["try"],
    dimensions = mac(),
)
nightly_builder(
    "analyzer-nnbd-win-release",
    category = "analyzer|nnbd|w",
    channels = ["try"],
    dimensions = windows(),
)

# sdk
dart_ci_builder(
    "dart-sdk-linux",
    category = "sdk|l",
    channels = CHANNELS,
    lkgr = True,
)
dart_ci_builder(
    "dart-sdk-mac",
    category = "sdk|m",
    channels = CHANNELS,
    dimensions = mac(),
    lkgr = True,
)
dart_ci_builder(
    "dart-sdk-win",
    category = "sdk|w",
    channels = CHANNELS,
    dimensions = windows(),
    on_cq = True,
    lkgr = True,
)

# ddc
dart_ci_sandbox_builder(
    "ddc-linux-release-chrome",
    category = "ddc|l",
    location_regexp = to_location_regexp(DDC_PATHS),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "ddc-nnbd-linux-release-chrome",
    category = "ddc|nn",
    channels = ["try"],
    location_regexp = to_location_regexp(DDC_PATHS),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "ddc-mac-release-chrome",
    category = "ddc|m",
    dimensions = mac(),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "ddc-win-release-chrome",
    category = "ddc|w",
    dimensions = windows(),
    properties = CHROME,
)
dart_ci_sandbox_builder(
    "ddk-linux-release-firefox",
    category = "ddc|fl",
    properties = FIREFOX,
)

# misc
dart_ci_sandbox_builder("gclient", recipe = "dart/gclient", category = "misc|g")
dart_ci_builder(
    "debianpackage-linux",
    category = "misc|dp",
    channels = RELEASE_CHANNELS,
    notifies = "infra",
    lkgr = True,
)

# external
dart_ci_sandbox_builder(
    "google",
    recipe = "dart/external",
    category = "flutter|g3",
    channels = [],
    execution_timeout = 5 * time.minute,
    lkgr = True,
    notifies = None,
    priority = HIGH,
    triggered_by = None,
)

# infra
dart_infra_builder(
    "base",
    execution_timeout = 15 * time.minute,
    recipe = "dart/forward_branch",
    schedule = "with 15m interval",
    notifies = None,
)
dart_infra_builder(
    "cbuild",
    recipe = "dart/cbuild",
    schedule = "with 15m interval",
    execution_timeout = 10 * time.minute,
)
dart_infra_builder("chocolatey", recipe = "dart/chocolatey", dimensions = windows())
dart_infra_builder("co19-roller", recipe = "dart/package_co19")
dart_infra_builder("docker", recipe = "dart/docker")
dart_infra_builder(
    "linearize-flutter",
    recipe = "dart/linearize",
    properties = {
        "repo": "https://dart.googlesource.com/linear_sdk_flutter_engine.git",
    },
    notifies = "infra",
    triggered_by = [
        "dart-gitiles-trigger-master",
        "dart-flutter-engine-trigger",
        "dart-flutter-flutter-trigger",
    ],
    triggering_policy = scheduler.greedy_batching(max_batch_size = 1),
)
dart_infra_builder(
    "lkgr",
    execution_timeout = 15 * time.minute,
    notifies = "infra",
    properties = {"builders": lkgr_builders, "ref": "refs/heads/lkgr"},
    recipe = "roller/lkgr",
    schedule = "with 15m interval",
)
dart_infra_builder(
    "roll-to-dev",
    bucket = "ci.roll",
    execution_timeout = 15 * time.minute,
    notifies = "infra",
    properties = {"from_ref": "refs/heads/lkgr"},
    recipe = "roller/roll_to_dev",
    schedule = "with 4h interval",
)
dart_infra_builder(
    "nightly",
    notifies = "infra",
    properties = {"builders": nightly_builders},
    recipe = "cron/cron",
    schedule = "0 5 * * *",  # daily, at 05:00 UTC
)
dart_infra_builder(
    "weekly",
    notifies = "infra",
    properties = {"builders": weekly_builders},
    recipe = "cron/cron",
    schedule = "0 0 * * SUN",  # weekly, midnight Saturday to Sunday
)

dart_ci_sandbox_builder(
    "ci-test-data",
    channels = [],
    properties = {"bisection_enabled": True},
    notifies = "ci-test-data",
    triggered_by = ["dart-ci-test-data-trigger"],
)

# Fuzz testing builders
dart_ci_sandbox_builder(
    "fuzz-linux",
    channels = [],
    notifies = "dart-fuzz-testing",
    schedule = "0 3,4 * * *",
    triggered_by = None,
)

# Try only builders
dart_try_builder("benchmark-linux", on_cq = True)

# Our sysroot does not support gcc, we can't use goma on RBE for this builder
dart_try_builder("vm-kernel-gcc-linux", goma_rbe = False)
dart_try_builder(
    "presubmit",
    bucket = "try.shared",
    execution_timeout = 10 * time.minute,
    recipe = "presubmit/presubmit",
)

def add_postponed_alt_console_entries():
    for entry in postponed_alt_console_entries:
        luci.console_view_entry(console_view = "alt", **entry)

add_postponed_alt_console_entries()

# Flutter consoles
luci.console_view_entry(
    builder = "flutter-analyze",
    short_name = "fa",
    category = "analyzer",
    console_view = "flutter",
)

luci.console_view_entry(
    builder = "flutter-frontend",
    short_name = "fl",
    category = "fasta",
    console_view = "flutter",
)

luci.console_view_entry(
    builder = "flutter-engine-linux",
    short_name = "3H",
    category = "flutter",
    console_view = "flutter-hhh",
)

luci.console_view_entry(
    builder = "flutter-engine-linux-web_tests",
    short_name = "web",
    category = "flutter",
    console_view = "flutter-hhh",
)

# Rolls dart recipe dependencies.
dart_infra_builder(
    name = "recipe-deps-roller",
    executable = luci.recipe(
        name = "recipe_autoroller",
        cipd_package =
            "infra/recipe_bundles/chromium.googlesource.com/infra/infra",
        cipd_version = "git_revision:905c1df843d7771bf3adc0cf21f58eb9498ff063",
    ),
    execution_timeout = 20 * time.minute,
    expiration_timeout = time.day,
    priority = LOW,
    properties = {
        "db_gcs_bucket": "dart-recipe-roller-db",
        "projects": {
            "dart": "https://dart.googlesource.com/recipes",
        }.items(),  # recipe_autoroller expects a list of tuples.
    },
    schedule = "with 4h interval",
)

dart_infra_builder(
    name = "recipe-bundler",
    executable = luci.recipe(
        name = "recipe_bundler",
        cipd_package =
            "infra/recipe_bundles/chromium.googlesource.com/infra/infra",
        cipd_version = "git_revision:40621e908eb88bd10451ee9d013b7ef89ea91e37",
    ),
    execution_timeout = 5 * time.minute,
    properties = {
        # This property controls the version of the recipe_bundler go tool:
        #   https://chromium.googlesource.com/infra/infra/+/master/go/src/infra/tools/recipe_bundler
        "recipe_bundler_vers": "git_revision:2ed88b2c854578b512e1c0486824175fe0d7aab6",
        # These control the prefix of the CIPD package names that the tool
        # will create.
        "package_name_prefix": "dart/recipe_bundles",
        "package_name_internal_prefix": "dart_internal/recipe_bundles",
        # Where to grab the recipes to bundle.
        "repo_specs": [
            "dart.googlesource.com/recipes=FETCH_HEAD,refs/heads/master",
        ],
    },
    schedule = "*/30 * * * *",
    triggered_by = [
        luci.gitiles_poller(
            name = "recipes-dart",
            bucket = "ci",
            repo = "https://dart.googlesource.com/recipes",
            refs = ["refs/heads/master"],
        ),
    ],
)
