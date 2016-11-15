using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Models;
using System.Data.SqlClient;
using System.Data;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class MSSQLSendForecastDao : ISendForecastDao
    {
        public SendForecast Find(string userName)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    var userId = dbCtx.SendInfo.Where(user => user.UserName == userName).Select(user => user.Id).FirstOrDefault();

                    return dbCtx.SendForecasts.Where(rec => rec.UserId == userId).ToList().FirstOrDefault(); 
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error finding send forecast info for user" + userName + " in database. " + e.Message, e);
            }
        }

        public SendForecast Insert(SendForecast send)
        {
            throw new NotImplementedException();
        }

        public string StorageProcetureCalling(DateTime date, Int64 condId, Int64 vitaminDId, Int64 melanomaRiskId, Int64 userId, Int64 appType)
        {
            SqlConnection conn = null;
            try
            {
                var pvConnectionString = System.Configuration.ConfigurationManager.ConnectionStrings["WeatherAppDbNoEntities"].ConnectionString;

                using (conn = new SqlConnection(pvConnectionString))
                using (SqlCommand cmd = new SqlCommand(Options.StorageProcedureName, conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add(Options.STParameter1Name, SqlDbType.BigInt);
                    cmd.Parameters.Add(Options.STParameter2Name, SqlDbType.BigInt);
                    cmd.Parameters.Add(Options.STParameter3Name, SqlDbType.BigInt);
                    cmd.Parameters.Add(Options.STParameter4Name, SqlDbType.DateTime);
                    cmd.Parameters.Add(Options.STParameter5Name, SqlDbType.BigInt);
                    cmd.Parameters.Add(Options.STParameter6Name, SqlDbType.BigInt);
                    cmd.Parameters.Add(Options.STOutputName, SqlDbType.VarChar, Options.STOutputMaxSize).Direction = ParameterDirection.Output;

                    cmd.Parameters[Options.STParameter1Name].Value = condId;
                    cmd.Parameters[Options.STParameter2Name].Value = vitaminDId;
                    cmd.Parameters[Options.STParameter3Name].Value = melanomaRiskId;
                    cmd.Parameters[Options.STParameter4Name].Value = date;
                    cmd.Parameters[Options.STParameter5Name].Value = userId;
                    cmd.Parameters[Options.STParameter6Name].Value = appType;

                    conn.Open();
                    cmd.ExecuteNonQuery();

                    return cmd.Parameters[Options.STOutputName].Value.ToString();                  
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error calling storage procedure. " + e.Message, e);
            }
            finally
            {
                conn.Close();
            }
        }
    }
}