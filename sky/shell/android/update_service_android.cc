// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "sky/shell/android/update_service_android.h"

#include "base/logging.h"
#include "base/task_runner_util.h"
#include "jni/UpdateService_jni.h"
#include "sky/engine/bindings/updater_snapshot.h"
#include "sky/engine/public/sky/sky_headless.h"
#include "sky/shell/shell.h"

namespace sky {
namespace shell {

static jlong CheckForUpdates(JNIEnv* env, jobject jcaller) {
  scoped_ptr<UpdateTaskAndroid> task(new UpdateTaskAndroid(env, jcaller));
  task->Start();
  return reinterpret_cast<jlong>(task.release());
}

bool RegisterUpdateService(JNIEnv* env) {
  return RegisterNativesImpl(env);
}

UpdateTaskAndroid::UpdateTaskAndroid(JNIEnv* env, jobject update_service)
    : headless_(new blink::SkyHeadless) {
  update_service_.Reset(env, update_service);
}

UpdateTaskAndroid::~UpdateTaskAndroid() {
}

void UpdateTaskAndroid::Start() {
  Shell::Shared().ui_task_runner()->PostTask(
      FROM_HERE, base::Bind(&UpdateTaskAndroid::RunDartOnUIThread,
                            base::Unretained(this)));
}

void UpdateTaskAndroid::RunDartOnUIThread() {
  // TODO(mpcomplete): pass variables into main.

  headless_->Init("sky:updater");
  headless_->RunFromSnapshotBuffer(kUpdaterSnapshotBuffer,
                                   kUpdaterSnapshotBufferSize);

  // TODO(mpcomplete): Have Dart notify us when done so we can notify Java
  // and be deleted. Or can Dart talk to Java directly?
}

void UpdateTaskAndroid::Finish() {
  // The Java side is responsible for deleting us when finished.
  Java_UpdateService_onUpdateFinished(base::android::AttachCurrentThread(),
                                      update_service_.obj());
}

void UpdateTaskAndroid::Destroy(JNIEnv* env, jobject jcaller) {
  delete this;
}

}  // namespace shell
}  // namespace sky
