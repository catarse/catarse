export interface Event<T = EventTarget> {
    target: T;
}

export type FileEventTarget = EventTarget & {
    target: {
        files: FileList
    }
}

export type HTMLInputEvent = Event & {
    target: HTMLInputElement
}