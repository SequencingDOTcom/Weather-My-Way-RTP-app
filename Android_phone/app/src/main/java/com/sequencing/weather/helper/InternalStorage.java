package com.sequencing.weather.helper;

import android.content.Context;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

public final class InternalStorage{

   public static void writeObject(Context context, String key, Object object) throws IOException {
      FileOutputStream fos = context.openFileOutput(key, Context.MODE_PRIVATE);
      ObjectOutputStream oos = new ObjectOutputStream(fos);
      oos.writeObject(object);
      oos.close();
      fos.close();
   }
 
   public static Object readObject(Context context, String key) throws IOException,
         ClassNotFoundException {
      FileInputStream fis = context.openFileInput(key);
      ObjectInputStream ois = new ObjectInputStream(fis);
      Object object = ois.readObject();
      ois.close();
      fis.close();
      return object;
   }
}